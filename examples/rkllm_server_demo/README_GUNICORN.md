# RKLLM Flask Server with Gunicorn

이 가이드는 RKLLM Flask 서버를 Gunicorn을 사용하여 프로덕션 환경에서 실행하는 방법을 설명합니다.

## 필요한 패키지 설치

```bash
pip install -r requirements.txt
```

## 사용법

### 방법 1: 제공된 스크립트 사용 (권장)

```bash
# 기본 사용법
./run_with_gunicorn.sh <model_path> <target_platform>

# LoRA 모델과 함께 사용
./run_with_gunicorn.sh <model_path> <target_platform> <lora_path> <cache_path>
```

**예시:**
```bash
./run_with_gunicorn.sh /path/to/model.rkllm rk3588
./run_with_gunicorn.sh /path/to/model.rkllm rk3588 /path/to/lora.bin /path/to/cache.bin
```

### 방법 2: 직접 Gunicorn 사용

1. 먼저 환경 변수를 설정합니다:
```bash
export RKLLM_MODEL_PATH="/path/to/your/model.rkllm"
export TARGET_PLATFORM="rk3588"  # 또는 rk3576
export LORA_MODEL_PATH="/path/to/lora.bin"  # (선택사항)
export PROMPT_CACHE_PATH="/path/to/cache.bin"  # (선택사항)
```

2. Gunicorn을 실행합니다:
```bash
cd rkllm_server
gunicorn --config ../gunicorn.conf.py wsgi:application
```

### 방법 3: 개발 모드 (Flask 내장 서버)

```bash
cd rkllm_server
python flask_server.py --rkllm_model_path /path/to/model.rkllm --target_platform rk3588
```

## Gunicorn 설정

`gunicorn.conf.py` 파일에서 다음과 같은 설정을 조정할 수 있습니다:

- `bind`: 서버 주소와 포트 (기본값: `0.0.0.0:8080`)
- `workers`: 워커 프로세스 수 (RKLLM 특성상 1로 설정됨)
- `timeout`: 요청 타임아웃 시간 (기본값: 120초)

## API 사용법

서버가 실행되면 다음 엔드포인트를 사용할 수 있습니다:

```bash
curl -X POST http://localhost:8080/rkllm_chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "rkllm",
    "messages": [{"role": "user", "content": "Hello, how are you?"}],
    "stream": false
  }'
```

## 주요 특징

1. **프로덕션 준비**: Gunicorn을 사용하여 안정적인 프로덕션 서버 운영
2. **자동 정리**: 서버 종료 시 자동으로 RKLLM 모델 리소스 해제
3. **에러 처리**: 모델 초기화 실패 및 런타임 에러에 대한 적절한 처리
4. **스레드 안전**: 멀티 요청 처리를 위한 락 메커니즘

## 문제 해결

### 모델 초기화 실패
- 모델 파일 경로가 올바른지 확인하세요
- 타겟 플랫폼이 rk3588 또는 rk3576인지 확인하세요
- 필요한 권한이 있는지 확인하세요

### 서버 응답 없음
- 포트 8080이 이미 사용 중인지 확인하세요
- 방화벽 설정을 확인하세요

### 메모리 부족
- `gunicorn.conf.py`에서 워커 수를 조정하세요 (이미 1로 설정됨) 