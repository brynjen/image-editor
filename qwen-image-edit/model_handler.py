"""
Model handler for Qwen Image Edit functionality.
Handles loading and inference with the Qwen image editing diffusion model.
"""

import os
import logging
from typing import Optional
from PIL import Image
import torch
from diffusers import QwenImageEditPipeline
import io
import base64

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class QwenImageEditHandler:
    """Handler for Qwen image editing model operations."""
    
    def __init__(self, model_name: str = "Qwen/Qwen-Image-Edit", device: str = "auto"):
        """
        Initialize the Qwen image edit handler.
        
        Args:
            model_name: HuggingFace model identifier
            device: Device to run inference on ('cpu', 'cuda', or 'auto')
        """
        self.model_name = model_name
        self.device = self._get_device(device)
        self.pipeline = None
        self._load_model()
    
    def _get_device(self, device: str) -> str:
        """Determine the best device to use for inference."""
        if device == "auto":
            return "cuda" if torch.cuda.is_available() else "cpu"
        return device
    
    def _load_model(self):
        """Load the Qwen image editing diffusion pipeline."""
        try:
            logger.info(f"Loading Qwen-Image-Edit pipeline {self.model_name} on {self.device}")
            
            # Load the diffusion pipeline
            self.pipeline = QwenImageEditPipeline.from_pretrained(
                self.model_name,
                torch_dtype=torch.bfloat16 if self.device == "cuda" else torch.float32,
            )
            
            # Move to device
            self.pipeline.to(self.device)
            
            # Configure progress bar
            self.pipeline.set_progress_bar_config(disable=True)
            
            logger.info("Qwen-Image-Edit pipeline loaded successfully")
            
        except Exception as e:
            logger.error(f"Failed to load pipeline: {e}")
            raise
    
    def process_image(self, image: Image.Image, prompt: str) -> Image.Image:
        """
        Process an image with the given text prompt using Qwen-Image-Edit pipeline.
        
        Args:
            image: PIL Image to process
            prompt: Text instruction for image editing
            
        Returns:
            Processed PIL Image
        """
        try:
            logger.info(f"Processing image with prompt: {prompt}")
            
            if self.pipeline is None:
                raise RuntimeError("Pipeline not loaded")
            
            # Convert image to RGB if needed
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Prepare inputs for the diffusion pipeline
            inputs = {
                "image": image,
                "prompt": prompt,
                "generator": torch.manual_seed(42),  # Fixed seed for reproducibility
                "true_cfg_scale": 4.0,
                "negative_prompt": "",
                "num_inference_steps": 50,
            }
            
            logger.info("Running diffusion inference...")
            
            # Run the diffusion pipeline
            with torch.inference_mode():
                output = self.pipeline(**inputs)
                processed_image = output.images[0]
            
            logger.info("Image processing completed successfully")
            return processed_image
            
        except Exception as e:
            logger.error(f"Error processing image: {e}")
            raise
    
    def encode_image_to_base64(self, image: Image.Image, format: str = "PNG") -> str:
        """Convert PIL Image to base64 string."""
        buffer = io.BytesIO()
        image.save(buffer, format=format)
        img_str = base64.b64encode(buffer.getvalue()).decode()
        return img_str
    
    def decode_image_from_base64(self, img_str: str) -> Image.Image:
        """Convert base64 string to PIL Image."""
        img_data = base64.b64decode(img_str)
        image = Image.open(io.BytesIO(img_data))
        return image
    
    def is_model_loaded(self) -> bool:
        """Check if the pipeline is loaded and ready."""
        return self.pipeline is not None
    
    def get_model_info(self) -> dict:
        """Get information about the loaded pipeline."""
        return {
            "model_name": self.model_name,
            "device": self.device,
            "loaded": self.is_model_loaded(),
            "cuda_available": torch.cuda.is_available(),
            "model_type": "diffusion_pipeline"
        }
