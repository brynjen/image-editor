#!/usr/bin/env python3
"""
Simple DFloat11 Model Downloader for Remote GPU Server
Downloads both base model and DFloat11 compressed weights directly
"""

import os
import sys
import logging
from pathlib import Path
from datetime import datetime

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('dfloat11_download.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def check_dependencies():
    """Check if required packages are installed"""
    try:
        import huggingface_hub
        import torch
        import transformers
        logger.info("✅ All required packages are available")
        return True
    except ImportError as e:
        logger.error(f"❌ Missing required package: {e}")
        logger.info("📦 Install with: pip install huggingface_hub torch transformers")
        return False

def setup_cache_directory():
    """Set up cache directory and environment variables"""
    cache_dir = Path("./qwen-models-cache")
    cache_dir.mkdir(exist_ok=True)
    
    # Set environment variables for HuggingFace cache
    os.environ['HF_HOME'] = str(cache_dir.absolute())
    os.environ['TRANSFORMERS_CACHE'] = str(cache_dir.absolute())
    os.environ['HF_DATASETS_CACHE'] = str(cache_dir.absolute())
    
    logger.info(f"📁 Cache directory: {cache_dir.absolute()}")
    return cache_dir

def check_disk_space():
    """Check available disk space"""
    import shutil
    total, used, free = shutil.disk_usage(".")
    free_gb = free / (1024**3)
    logger.info(f"💾 Available disk space: {free_gb:.1f} GB")
    
    if free_gb < 35:
        logger.warning(f"⚠️  Low disk space! Need ~35GB, have {free_gb:.1f}GB")
        return False
    return True

def download_model(repo_id, description):
    """Download a single model"""
    from huggingface_hub import snapshot_download
    
    logger.info(f"📥 Downloading {description}")
    logger.info(f"🔗 Repository: {repo_id}")
    
    try:
        start_time = datetime.now()
        
        model_path = snapshot_download(
            repo_id=repo_id,
            cache_dir=os.environ['HF_HOME'],
            resume_download=True,
            local_files_only=False,
        )
        
        end_time = datetime.now()
        duration = end_time - start_time
        
        logger.info(f"✅ {description} downloaded successfully!")
        logger.info(f"📍 Path: {model_path}")
        logger.info(f"⏱️  Duration: {duration}")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Failed to download {description}: {e}")
        return False

def check_download_status(cache_dir):
    """Check if both models are downloaded"""
    base_model_files = list(cache_dir.glob("**/model_index.json"))
    dfloat11_dirs = list(cache_dir.glob("**/models--DFloat11--*"))
    
    base_found = len(base_model_files) > 0
    dfloat11_found = len(dfloat11_dirs) > 0
    
    logger.info(f"📊 Download Status:")
    logger.info(f"   📁 Base model: {'✅ Found' if base_found else '❌ Missing'}")
    logger.info(f"   🗜️  DFloat11 model: {'✅ Found' if dfloat11_found else '❌ Missing'}")
    
    if base_found and dfloat11_found:
        # Check for actual model files
        dfloat11_files = []
        for dfloat11_dir in dfloat11_dirs:
            dfloat11_files.extend(dfloat11_dir.rglob("*.bin"))
            dfloat11_files.extend(dfloat11_dir.rglob("*.safetensors"))
        
        if dfloat11_files:
            logger.info(f"🎉 Both models downloaded successfully!")
            logger.info(f"📊 DFloat11 files found: {len(dfloat11_files)}")
            return True
    
    return False

def main():
    """Main download function"""
    logger.info("🤖 DFloat11 Model Downloader for Remote GPU Server")
    logger.info("=" * 55)
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Check disk space
    if not check_disk_space():
        response = input("Continue anyway? [y/N]: ")
        if response.lower() != 'y':
            sys.exit(1)
    
    # Setup cache directory
    cache_dir = setup_cache_directory()
    
    # Check if already downloaded
    if check_download_status(cache_dir):
        logger.info("🎯 Models already downloaded! Nothing to do.")
        return
    
    # Models to download
    models = [
        ("Qwen/Qwen-Image-Edit", "Base Qwen-Image-Edit model"),
        ("DFloat11/Qwen-Image-Edit-DF11", "DFloat11 compressed weights")
    ]
    
    logger.info(f"📦 Starting download of {len(models)} model components...")
    logger.info(f"🌐 This will download ~28GB total")
    
    # Download each model
    success_count = 0
    for repo_id, description in models:
        if download_model(repo_id, description):
            success_count += 1
        else:
            logger.error(f"💥 Failed to download {description}")
    
    # Final status check
    logger.info("=" * 55)
    logger.info(f"📊 Download Summary:")
    logger.info(f"   ✅ Successful: {success_count}/{len(models)}")
    
    if success_count == len(models):
        logger.info("🎉 All models downloaded successfully!")
        
        # Final verification
        if check_download_status(cache_dir):
            logger.info("✅ Verification passed - ready for GPU processing!")
            
            # Show cache size
            import shutil
            cache_size = shutil.disk_usage(cache_dir)
            used_gb = (cache_size.total - cache_size.free) / (1024**3)
            logger.info(f"💾 Cache directory size: ~{used_gb:.1f}GB")
            
        else:
            logger.error("❌ Verification failed - some files may be missing")
            sys.exit(1)
    else:
        logger.error("💥 Download incomplete - please retry")
        sys.exit(1)

if __name__ == "__main__":
    main()
