# Build API
FROM python:3.11-slim as api-builder

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set the working directory
WORKDIR /app

# Copy API files
COPY philoagents-api/uv.lock philoagents-api/pyproject.toml philoagents-api/README.md ./
RUN uv sync --frozen --no-cache

COPY philoagents-api/src/philoagents philoagents/
COPY philoagents-api/tools tools/

# Build UI
FROM node:18-alpine as ui-builder

WORKDIR /app

# Copy UI files
COPY philoagents-ui/package*.json ./
RUN npm install

COPY philoagents-ui/ ./
RUN npm run build

# Final stage
FROM python:3.11-slim

WORKDIR /app

# Copy API files from api-builder
COPY --from=api-builder /app /app/api
COPY --from=api-builder /app/.venv /app/.venv

# Copy UI files from ui-builder
COPY --from=ui-builder /app/dist /app/ui/dist

# Install nginx
RUN apt-get update && apt-get install -y nginx

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Set environment variables
ENV PORT=8000
ENV HOST=0.0.0.0

# Expose port
EXPOSE ${PORT}

# Start both services
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"] 