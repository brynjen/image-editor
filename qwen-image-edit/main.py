"""
FastAPI server for Qwen Image Edit service.
Provides HTTP endpoints for image processing using Qwen models.
"""

import os
import logging
import asyncio
from typing import Optional
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from PIL import Image
import io
import base64
import requests

from model_handler import QwenImageEditHandler

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Qwen Image Edit Service",
    description="AI-powered image editing using Qwen models",
    version="1.0.0"
)

# Global model handler
model_handler: Optional[QwenImageEditHandler] = None

class ProcessRequest(BaseModel):
    """Request model for image processing."""
    image_base64: str
    prompt: str
    model: Optional[str] = "qwen-image-edit"
    options: Optional[dict] = {}

class ProcessResponse(BaseModel):
    """Response model for image processing."""
    success: bool
    processed_image_base64: Optional[str] = None
    processing_time: Optional[float] = None
    model_used: Optional[str] = None
    message: Optional[str] = None

class HealthResponse(BaseModel):
    """Response model for health check."""
    status: str
    model_loaded: bool
    model_info: dict

@app.on_event("startup")
async def startup_event():
    """Initialize the model on startup."""
    global model_handler
    try:
        logger.info("Starting Qwen Image Edit service...")
        
        # Get configuration from environment variables
        model_name = os.getenv("MODEL_NAME", "Qwen/Qwen-Image-Edit")
        device = os.getenv("DEVICE", "auto")
        
        logger.info(f"Initializing model: {model_name} on {device}")
        model_handler = QwenImageEditHandler(model_name=model_name, device=device)
        
        logger.info("Qwen Image Edit service started successfully")
        
    except Exception as e:
        logger.error(f"Failed to initialize service: {e}")
        # Don't raise here - let the service start but mark as unhealthy
        model_handler = None

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    global model_handler
    
    if model_handler is None:
        return HealthResponse(
            status="unhealthy",
            model_loaded=False,
            model_info={"error": "Model handler not initialized"}
        )
    
    try:
        model_info = model_handler.get_model_info()
        return HealthResponse(
            status="healthy" if model_handler.is_model_loaded() else "unhealthy",
            model_loaded=model_handler.is_model_loaded(),
            model_info=model_info
        )
    except Exception as e:
        return HealthResponse(
            status="unhealthy",
            model_loaded=False,
            model_info={"error": str(e)}
        )

@app.get("/models")
async def get_models():
    """Get available models and capabilities."""
    return {
        "available_models": ["qwen-image-edit"],
        "capabilities": ["image_editing", "background_removal", "object_manipulation"],
        "supported_formats": ["PNG", "JPEG", "WebP"]
    }

@app.post("/process", response_model=ProcessResponse)
async def process_image(request: ProcessRequest):
    """
    Process an image with the given text prompt.
    
    Args:
        request: ProcessRequest containing image and prompt
        
    Returns:
        ProcessResponse with processed image or error
    """
    global model_handler
    
    if model_handler is None or not model_handler.is_model_loaded():
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Service unavailable."
        )
    
    try:
        import time
        start_time = time.time()
        
        logger.info(f"Processing image with prompt: {request.prompt}")
        
        # Decode input image
        try:
            input_image = model_handler.decode_image_from_base64(request.image_base64)
        except Exception as e:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid image data: {str(e)}"
            )
        
        # Process the image
        processed_image = model_handler.process_image(input_image, request.prompt)
        
        # Encode result
        processed_image_base64 = model_handler.encode_image_to_base64(processed_image)
        
        processing_time = time.time() - start_time
        
        return ProcessResponse(
            success=True,
            processed_image_base64=processed_image_base64,
            processing_time=processing_time,
            model_used=model_handler.model_name,
            message="Image processed successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing image: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Processing failed: {str(e)}"
        )

@app.post("/process-multipart")
async def process_image_multipart(
    file: UploadFile = File(...),
    prompt: str = Form(...),
    model: Optional[str] = Form("qwen-image-edit")
):
    """
    Process an image uploaded as multipart form data.
    Alternative endpoint for file upload.
    """
    global model_handler
    
    if model_handler is None or not model_handler.is_model_loaded():
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Service unavailable."
        )
    
    try:
        import time
        start_time = time.time()
        
        # Validate file type
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(
                status_code=400,
                detail="File must be an image"
            )
        
        # Read and process image
        image_data = await file.read()
        input_image = Image.open(io.BytesIO(image_data))
        
        # Process the image
        processed_image = model_handler.process_image(input_image, prompt)
        
        # Encode result
        processed_image_base64 = model_handler.encode_image_to_base64(processed_image)
        
        processing_time = time.time() - start_time
        
        return ProcessResponse(
            success=True,
            processed_image_base64=processed_image_base64,
            processing_time=processing_time,
            model_used=model_handler.model_name,
            message="Image processed successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing image: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Processing failed: {str(e)}"
        )

@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "service": "Qwen Image Edit",
        "version": "1.0.0",
        "status": "running",
        "endpoints": ["/health", "/models", "/process", "/process-multipart"]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
