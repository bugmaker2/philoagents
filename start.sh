#!/bin/bash

# Start nginx in the background
nginx

# Start the API server
cd /app/api
/app/.venv/bin/fastapi run philoagents/infrastructure/api.py --port 8001 --host 0.0.0.0 