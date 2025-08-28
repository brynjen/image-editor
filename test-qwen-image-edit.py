#!/usr/bin/env python3
"""
Test script for Qwen Image Edit FastAPI service.
Based on the HuggingFace DFloat11/Qwen-Image-Edit-DF11 example.
"""

import requests
import base64
import json
import time
from PIL import Image
from io import BytesIO

def encode_image_to_base64(image_path_or_url: str) -> str:
    """Convert image to base64 string."""
    if image_path_or_url.startswith('http'):
        # Download image from URL
        response = requests.get(image_path_or_url)
        response.raise_for_status()
        image_data = response.content
    else:
        # Read local file
        with open(image_path_or_url, 'rb') as f:
            image_data = f.read()
    
    return base64.b64encode(image_data).decode('utf-8')

def decode_base64_to_image(base64_string: str) -> Image.Image:
    """Convert base64 string to PIL Image."""
    image_data = base64.b64decode(base64_string)
    return Image.open(BytesIO(image_data))

def test_qwen_image_edit_service(server_url: str = "http://localhost:8000"):
    """Test the Qwen Image Edit FastAPI service."""
    print("🧪 Testing Qwen Image Edit Service")
    print(f"📡 Server URL: {server_url}")
    print("=" * 50)
    
    # Test 1: Health Check
    print("\n1️⃣ Testing Health Check...")
    try:
        response = requests.get(f"{server_url}/health", timeout=10)
        if response.status_code == 200:
            health_data = response.json()
            print(f"✅ Health Check: {health_data['status']}")
            print(f"🤖 Model Loaded: {health_data['model_loaded']}")
            if 'model_info' in health_data:
                model_info = health_data['model_info']
                print(f"📦 Model: {model_info.get('model_name', 'unknown')}")
                print(f"💾 Device: {model_info.get('device', 'unknown')}")
                print(f"🔧 Type: {model_info.get('model_type', 'unknown')}")
        else:
            print(f"❌ Health Check Failed: HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health Check Error: {e}")
        return False
    
    # Test 2: Image Processing
    print("\n2️⃣ Testing Image Processing...")
    
    # Use the same test image as HuggingFace example
    test_image_url = "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/diffusers/cat.png"
    test_prompt = "Add a hat to the cat."
    
    try:
        print(f"📸 Loading test image: {test_image_url}")
        image_base64 = encode_image_to_base64(test_image_url)
        print(f"✅ Image encoded (size: {len(image_base64)} chars)")
        
        # Prepare request with HuggingFace DFloat11 example parameters
        request_data = {
            "image_base64": image_base64,
            "prompt": test_prompt,
            "negative_prompt": " ",  # Space as recommended in HF docs
            "num_inference_steps": 50,
            "true_cfg_scale": 4.0,
            "seed": 42
        }
        
        print(f"🎯 Processing with prompt: '{test_prompt}'")
        print("⏳ This may take several minutes (especially on CPU)...")
        
        start_time = time.time()
        response = requests.post(
            f"{server_url}/process",
            json=request_data,
            timeout=600  # 10 minutes timeout
        )
        processing_time = time.time() - start_time
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Processing successful!")
            print(f"⏱️  Processing time: {result.get('processing_time', processing_time):.2f} seconds")
            print(f"🤖 Model used: {result.get('model_used', 'unknown')}")
            
            # Save result image
            if result.get('processed_image_base64'):
                output_image = decode_base64_to_image(result['processed_image_base64'])
                output_path = "qwen_image_edit_result.png"
                output_image.save(output_path)
                print(f"💾 Result saved to: {output_path}")
                print(f"📏 Output size: {output_image.size}")
            
            return True
        else:
            print(f"❌ Processing failed: HTTP {response.status_code}")
            print(f"📝 Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Processing error: {e}")
        return False

def main():
    """Main test function."""
    print("🚀 Qwen Image Edit FastAPI Service Test")
    print("Based on HuggingFace DFloat11/Qwen-Image-Edit-DF11")
    print("=" * 60)
    
    # Test different server configurations
    servers_to_test = [
        "http://localhost:8000",  # Local development
        # Add your remote GPU server here:
        # "http://192.168.1.100:8000",  # Remote RTX 4090 server
    ]
    
    for server_url in servers_to_test:
        print(f"\n🌐 Testing server: {server_url}")
        success = test_qwen_image_edit_service(server_url)
        if success:
            print(f"✅ Server {server_url} test passed!")
        else:
            print(f"❌ Server {server_url} test failed!")
        print("-" * 50)

if __name__ == "__main__":
    main()
