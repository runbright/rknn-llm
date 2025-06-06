#!/bin/bash

# RKLLM Flask Server with Gunicorn

# 필수 파라미터 확인
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <rkllm_model_path> <target_platform> [lora_model_path] [prompt_cache_path]"
    echo "Example: $0 /path/to/model.rkllm rk3588"
    echo "Example: $0 /path/to/model.rkllm rk3588 /path/to/lora.bin /path/to/cache.bin"
    exit 1
fi

RKLLM_MODEL_PATH="$1"
TARGET_PLATFORM="$2"
LORA_MODEL_PATH="$3"
PROMPT_CACHE_PATH="$4"

# 현재 디렉토리를 rkllm_server로 변경
cd "$(dirname "$0")/rkllm_server"

# 환경 변수 설정
export RKLLM_MODEL_PATH="$RKLLM_MODEL_PATH"
export TARGET_PLATFORM="$TARGET_PLATFORM"
export LORA_MODEL_PATH="$LORA_MODEL_PATH"
export PROMPT_CACHE_PATH="$PROMPT_CACHE_PATH"

# RKLLM 모델 초기화를 위한 임시 Python 스크립트 생성
cat > init_model.py << EOF
import sys
import os
sys.path.insert(0, '.')
from flask_server import initialize_model

# 환경 변수에서 설정 읽기
model_path = os.environ.get('RKLLM_MODEL_PATH')
target_platform = os.environ.get('TARGET_PLATFORM')
lora_model_path = os.environ.get('LORA_MODEL_PATH')
prompt_cache_path = os.environ.get('PROMPT_CACHE_PATH')

# 빈 문자열을 None으로 변경
if lora_model_path == '':
    lora_model_path = None
if prompt_cache_path == '':
    prompt_cache_path = None

# 모델 초기화
success = initialize_model(model_path, target_platform, lora_model_path, prompt_cache_path)
if not success:
    sys.exit(1)
    
print("Model initialization completed successfully!")
EOF

# 모델 초기화
echo "Initializing RKLLM model..."
python3 init_model.py
if [ $? -ne 0 ]; then
    echo "Failed to initialize RKLLM model"
    rm -f init_model.py
    exit 1
fi

# 임시 파일 삭제
rm -f init_model.py

echo "Starting RKLLM Flask server with Gunicorn..."

# Gunicorn으로 Flask 애플리케이션 실행
gunicorn --config ../gunicorn.conf.py --chdir . flask_server:app

echo "RKLLM Flask server stopped." 