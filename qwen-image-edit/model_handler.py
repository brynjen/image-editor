"""
Model handler for Qwen Image Edit functionality using DFloat11 compression.
Handles loading and inference with the compressed Qwen image editing diffusion model.
"""

import os
import logging
from typing import Optional
from PIL import Image
import torch
from diffusers import QwenImageTransformer2DModel, QwenImageEditPipeline
from transformers.modeling_utils import no_init_weights
from dfloat11 import DFloat11Model
import io
import base64

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class QwenImageEditHandler:
    """Handler for DFloat11 compressed Qwen image editing model operations."""
    
    def __init__(self, model_name: str = "Qwen/Qwen-Image-Edit", device: str = "auto", cpu_offload: bool = True):
        """
        Initialize the DFloat11 compressed Qwen image edit handler.
        
        Args:
            model_name: Base HuggingFace model identifier (always Qwen/Qwen-Image-Edit)
            device: Device to run inference on ('cpu', 'cuda', or 'auto')
            cpu_offload: Enable CPU offloading to reduce GPU memory usage
        """
        self.model_name = model_name
        self.dfloat11_model_name = "DFloat11/Qwen-Image-Edit-DF11"
        self.device = self._get_device(device)
        self.cpu_offload = cpu_offload
        self.pipeline = None
        self._load_model()
    
    def _get_device(self, device: str) -> str:
        """Determine the best device to use for inference."""
        if device == "auto":
            return "cuda" if torch.cuda.is_available() else "cpu"
        return device
    
    def _load_model(self):
        """Load the DFloat11 compressed Qwen image editing pipeline."""
        try:
            logger.info(f"Loading DFloat11 compressed Qwen-Image-Edit pipeline")
            logger.info(f"Base model: {self.model_name}")
            logger.info(f"Compressed model: {self.dfloat11_model_name}")
            logger.info(f"Device: {self.device}, CPU Offload: {self.cpu_offload}")
            
            # Step 1: Load the transformer config without weights
            with no_init_weights():
                transformer = QwenImageTransformer2DModel.from_config(
                    QwenImageTransformer2DModel.load_config(
                        self.model_name, subfolder="transformer",
                    ),
                ).to(torch.bfloat16)
            
            logger.info("Transformer config loaded, loading DFloat11 compressed weights...")
            
            # Step 2: Load DFloat11 compressed weights into the transformer
            DFloat11Model.from_pretrained(
                self.dfloat11_model_name,
                device="cpu",  # Always load to CPU first
                cpu_offload=self.cpu_offload,
                cpu_offload_blocks=30 if self.cpu_offload else 0,
                pin_memory=True,
                bfloat16_model=transformer,
            )
            
            logger.info("DFloat11 weights loaded, creating pipeline...")
            
            # Step 3: Create the full pipeline with the compressed transformer
            self.pipeline = QwenImageEditPipeline.from_pretrained(
                self.model_name,
                transformer=transformer,
                torch_dtype=torch.bfloat16,
            )
            
            # Enable CPU offloading for the entire pipeline to save memory
            if self.cpu_offload or self.device == "cpu":
                self.pipeline.enable_model_cpu_offload()
                logger.info("CPU offloading enabled for pipeline")
            else:
                self.pipeline.to(self.device)
            
            # Configure progress bar (disable for API usage)
            self.pipeline.set_progress_bar_config(disable=True)
            
            logger.info("DFloat11 compressed Qwen-Image-Edit pipeline loaded successfully")
            
        except Exception as e:
            logger.error(f"Failed to load DFloat11 compressed pipeline: {e}")
            raise
    
    def process_image(self, image: Image.Image, prompt: str, **kwargs) -> Image.Image:
        """
        Process an image with the given text prompt using DFloat11 compressed pipeline.
        
        Args:
            image: PIL Image to process
            prompt: Text instruction for image editing
            **kwargs: Additional parameters for the pipeline
            
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
            
            # Default parameters optimized for DFloat11 model
            default_params = {
                "generator": torch.manual_seed(42),  # Fixed seed for reproducibility
                "true_cfg_scale": 4.0,
                "negative_prompt": " ",  # Space as recommended in docs
                "num_inference_steps": 50,
            }
            
            # Merge with any provided kwargs
            default_params.update(kwargs)
            
            # Prepare inputs for the diffusion pipeline
            inputs = {
                "image": image,
                "prompt": prompt,
                **default_params
            }
            
            logger.info("Running DFloat11 compressed diffusion inference...")
            
            # Run the diffusion pipeline with inference mode
            with torch.inference_mode():
                output = self.pipeline(**inputs)
                processed_image = output.images[0]
            
            # Log GPU memory usage if CUDA is available
            if torch.cuda.is_available():
                max_gpu_memory = torch.cuda.max_memory_allocated()
                logger.info(f"Max GPU memory allocated: {max_gpu_memory / 1000 ** 3:.2f} GB")
            
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
            "dfloat11_model_name": self.dfloat11_model_name,
            "device": self.device,
            "cpu_offload": self.cpu_offload,
            "loaded": self.is_model_loaded(),
            "cuda_available": torch.cuda.is_available(),
            "model_type": "dfloat11_compressed_diffusion_pipeline",
            "compression_ratio": "32% smaller than original",
            "estimated_size": "28.43 GB"
        }