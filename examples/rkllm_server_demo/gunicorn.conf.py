# Gunicorn configuration file
bind = "0.0.0.0:8080"
workers = 1  # RKLLM 모델은 멀티프로세싱 지원하지 않으므로 1개 워커만 사용
worker_class = "sync"
worker_connections = 1000
timeout = 120
keepalive = 2
max_requests = 0
max_requests_jitter = 0
preload_app = False  # RKLLM 모델 초기화 문제를 피하기 위해 False로 설정
reload = False
pidfile = "/tmp/gunicorn.pid"
user = None
group = None
tmp_upload_dir = None
secure_scheme_headers = {
    'X-FORWARDED-PROTOCOL': 'ssl',
    'X-FORWARDED-PROTO': 'https',
    'X-FORWARDED-SSL': 'on'
} 