#!/bin/bash

# Simple Gunicorn startup script for RKLLM Flask Server
# Usage: Set environment variables and run this script

echo "Starting RKLLM Flask Server with Gunicorn..."

# 환경 변수 확인
if [ -z "$RKLLM_MODEL_PATH" ] || [ -z "$TARGET_PLATFORM" ]; then
    echo "Error: Required environment variables are not set"
    echo ""
    echo "Please set the following environment variables:"
    echo "  export RKLLM_MODEL_PATH='/path/to/your/model.rkllm'"
    echo "  export TARGET_PLATFORM='rk3588'  # or rk3576"
    echo ""
    echo "Optional environment variables:"
    echo "  export LORA_MODEL_PATH='/path/to/lora.bin'"
    echo "  export PROMPT_CACHE_PATH='/path/to/cache.bin'"
    echo ""
    echo "Then run: $0"
    exit 1
fi

echo "Configuration:"
echo "  Model Path: $RKLLM_MODEL_PATH"
echo "  Target Platform: $TARGET_PLATFORM"
echo "  LoRA Model Path: ${LORA_MODEL_PATH:-'Not set'}"
echo "  Prompt Cache Path: ${PROMPT_CACHE_PATH:-'Not set'}"
echo ""

# rkllm_server 디렉토리로 이동
cd "$(dirname "$0")/rkllm_server"

# Gunicorn 실행
echo "Starting Gunicorn..."
gunicorn --config ../gunicorn.conf.py wsgi:application 