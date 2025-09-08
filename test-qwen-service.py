#!/usr/bin/env python3
"""
Test script for Qwen Image Edit service
Tests the Docker container and API endpoints
"""

import requests
import json
import time
import base64
from PIL import Image
import io

def test_health_endpoint(base_url="http://localhost:8000"):
    """Test the health endpoint"""
    print("🔍 Testing health endpoint...")
    
    try:
        response = requests.get(f"{base_url}/health", timeout=10)
        if response.status_code == 200:
            health_data = response.json()
            print("✅ Health endpoint responding")
            print(f"   Status: {health_data.get('status', 'unknown')}")
            print(f"   Model loaded: {health_data.get('model_loaded', 'unknown')}")
            
            model_info = health_data.get('model_info', {})
            if model_info:
                print(f"   Model: {model_info.get('model_name', 'unknown')}")
                print(f"   Device: {model_info.get('device', 'unknown')}")
                print(f"   Type: {model_info.get('model_type', 'unknown')}")
            
            return health_data.get('model_loaded', False)
        else:
            print(f"❌ Health endpoint error: {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection failed: {e}")
        return False

def test_models_endpoint(base_url="http://localhost:8000"):
    """Test the models endpoint"""
    print("\n🔍 Testing models endpoint...")
    
    try:
        response = requests.get(f"{base_url}/models", timeout=10)
        if response.status_code == 200:
            models_data = response.json()
            print("✅ Models endpoint responding")
            print(f"   Available models: {models_data.get('available_models', [])}")
            print(f"   Capabilities: {models_data.get('capabilities', [])}")
            return True
        else:
            print(f"❌ Models endpoint error: {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection failed: {e}")
        return False

def create_test_image():
    """Create a simple test image"""
    # Create a 512x512 red square
    image = Image.new('RGB', (512, 512), color='red')
    
    # Convert to base64
    buffer = io.BytesIO()
    image.save(buffer, format='PNG')
    img_str = base64.b64encode(buffer.getvalue()).decode()
    
    return img_str

def test_process_endpoint(base_url="http://localhost:8000"):
    """Test the image processing endpoint"""
    print("\n🔍 Testing image processing endpoint...")
    
    try:
        # Create test image
        test_image_b64 = create_test_image()
        
        # Prepare request
        payload = {
            "image_base64": test_image_b64,
            "prompt": "Make this image blue instead of red",
            "num_inference_steps": 20,  # Reduced for faster testing
            "seed": 42
        }
        
        print("📤 Sending test image for processing...")
        print(f"   Prompt: {payload['prompt']}")
        
        start_time = time.time()
        response = requests.post(
            f"{base_url}/process", 
            json=payload, 
            timeout=300  # 5 minute timeout for processing
        )
        processing_time = time.time() - start_time
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Image processing successful!")
            print(f"   Processing time: {processing_time:.1f}s")
            print(f"   Server reported time: {result.get('processing_time', 'unknown'):.1f}s")
            print(f"   Model used: {result.get('model_used', 'unknown')}")
            
            # Save result if available
            if result.get('processed_image_base64'):
                try:
                    img_data = base64.b64decode(result['processed_image_base64'])
                    result_image = Image.open(io.BytesIO(img_data))
                    result_image.save('test_result.png')
                    print("💾 Result saved as test_result.png")
                except Exception as e:
                    print(f"⚠️  Could not save result image: {e}")
            
            return True
        else:
            print(f"❌ Processing failed: {response.status_code}")
            try:
                error_data = response.json()
                print(f"   Error: {error_data.get('detail', 'Unknown error')}")
            except:
                print(f"   Raw response: {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print("❌ Processing timed out (>5 minutes)")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection failed: {e}")
        return False

def main():
    """Main test function"""
    print("🧪 Qwen Image Edit Service Test")
    print("=" * 40)
    
    base_url = "http://localhost:8000"
    
    # Test 1: Health check
    model_loaded = test_health_endpoint(base_url)
    
    # Test 2: Models endpoint
    models_ok = test_models_endpoint(base_url)
    
    # Test 3: Image processing (only if model is loaded)
    if model_loaded:
        print("\n🚀 Model is loaded, testing image processing...")
        processing_ok = test_process_endpoint(base_url)
    else:
        print("\n⚠️  Model not loaded, skipping processing test")
        processing_ok = False
    
    # Summary
    print("\n" + "=" * 40)
    print("📊 Test Summary:")
    print(f"   Health endpoint: {'✅' if model_loaded else '❌'}")
    print(f"   Models endpoint: {'✅' if models_ok else '❌'}")
    print(f"   Image processing: {'✅' if processing_ok else '❌' if model_loaded else '⏭️  Skipped'}")
    
    if model_loaded and models_ok and processing_ok:
        print("\n🎉 All tests passed! Service is fully functional.")
        return 0
    elif model_loaded and models_ok:
        print("\n⚠️  Service is running but image processing failed.")
        return 1
    else:
        print("\n❌ Service is not fully operational.")
        return 1

if __name__ == "__main__":
    exit(main())
