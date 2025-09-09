#!/usr/bin/env python3
"""
Test DFloat11 Model Download
Tests the DFloat11 library's ability to download and cache the compressed model properly.
This allows the DFloat11 library to handle the XET chunked download system correctly.
"""

import torch
from diffusers import QwenImageTransformer2DModel, QwenImageEditPipeline
from transformers.modeling_utils import no_init_weights
from dfloat11 import DFloat11Model
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    # Set cache directory
    cache_dir = './qwen-models-cache'
    os.environ['HF_HOME'] = cache_dir
    os.environ['TRANSFORMERS_CACHE'] = cache_dir
    os.environ['HF_DATASETS_CACHE'] = cache_dir
    
    model_id = "Qwen/Qwen-Image-Edit"
    dfloat11_model_id = "DFloat11/Qwen-Image-Edit-DF11"
    
    logger.info("Starting DFloat11 model download test...")
    logger.info(f"Cache directory: {cache_dir}")
    logger.info(f"Base model: {model_id}")
    logger.info(f"DFloat11 model: {dfloat11_model_id}")
    
    try:
        logger.info("Step 1: Loading transformer config without weights...")
        with no_init_weights():
            transformer = QwenImageTransformer2DModel.from_config(
                QwenImageTransformer2DModel.load_config(
                    model_id, subfolder="transformer",
                ),
            ).to(torch.bfloat16)
        
        logger.info("✅ Transformer config loaded successfully")
        
        logger.info("Step 2: Loading DFloat11 compressed model...")
        logger.info("This will download the compressed model chunks through DFloat11's system")
        logger.info("Expected download: ~28GB in chunks via XET system")
        
        DFloat11Model.from_pretrained(
            dfloat11_model_id,
            device="cpu",  # Load to CPU first as recommended
            cpu_offload=True,
            cpu_offload_blocks=30,
            pin_memory=True,
            bfloat16_model=transformer,
        )
        
        logger.info("✅ DFloat11 compressed model loaded successfully!")
        logger.info("The model chunks have been properly cached")
        
        logger.info("Step 3: Creating full pipeline...")
        pipeline = QwenImageEditPipeline.from_pretrained(
            model_id, 
            transformer=transformer, 
            torch_dtype=torch.bfloat16,
        )
        pipeline.enable_model_cpu_offload()
        
        logger.info("✅ Pipeline created successfully!")
        logger.info("🎉 DFloat11 model is ready for use!")
        
        # Check GPU memory if available
        if torch.cuda.is_available():
            max_gpu_memory = torch.cuda.max_memory_allocated()
            logger.info(f"Max GPU memory allocated: {max_gpu_memory / 1000 ** 3:.2f} GB")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Failed to load DFloat11 model: {e}")
        return False

if __name__ == "__main__":
    success = main()
    if success:
        print("\n🎉 SUCCESS: DFloat11 model download and setup completed!")
        print("You can now run the Docker container with the properly cached model.")
    else:
        print("\n💥 FAILED: DFloat11 model download failed.")
        print("Check the error messages above for details.")
