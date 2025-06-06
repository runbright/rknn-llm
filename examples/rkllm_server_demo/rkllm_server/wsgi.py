"""
WSGI entry point for Gunicorn
"""
import os
import sys
from flask_server import app, initialize_model

def create_app():
    """Application factory for Gunicorn"""
    
    # 환경 변수에서 모델 설정 읽기
    model_path = os.environ.get('RKLLM_MODEL_PATH')
    target_platform = os.environ.get('TARGET_PLATFORM')
    lora_model_path = os.environ.get('LORA_MODEL_PATH')
    prompt_cache_path = os.environ.get('PROMPT_CACHE_PATH')
    
    # 필수 파라미터 체크
    if not model_path or not target_platform:
        print("Error: RKLLM_MODEL_PATH and TARGET_PLATFORM environment variables are required")
        print("Set them before running gunicorn:")
        print("export RKLLM_MODEL_PATH='/path/to/your/model.rkllm'")
        print("export TARGET_PLATFORM='rk3588'  # or rk3576")
        print("gunicorn --config ../gunicorn.conf.py wsgi:application")
        sys.exit(1)
    
    # 빈 문자열을 None으로 변경
    if lora_model_path == '':
        lora_model_path = None
    if prompt_cache_path == '':
        prompt_cache_path = None
    
    # 모델 초기화
    print("Initializing RKLLM model...")
    success = initialize_model(model_path, target_platform, lora_model_path, prompt_cache_path)
    if not success:
        print("Failed to initialize RKLLM model")
        sys.exit(1)
    
    print("RKLLM model initialized successfully!")
    return app

# Gunicorn이 사용할 애플리케이션 객체
application = create_app() 