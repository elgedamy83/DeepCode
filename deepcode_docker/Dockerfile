# ------ Stage 1: Build frontend static assets ------
FROM node:18-bullseye-slim AS frontend-builder  # switch to Debian-based

WORKDIR /build
COPY new_ui/frontend/package*.json ./
RUN npm ci --no-audit --no-fund
COPY new_ui/frontend/ ./
RUN npm run build

# ------ Stage 2: Final image ------
FROM python:3.10-slim

LABEL maintainer="DeepCode Team"
LABEL description="DeepCode - CPU-only AI Research Engine"
LABEL version="1.0"

# Environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEEPCODE_ENV=docker \
    DEEPCODE_HOST=0.0.0.0 \
    DEEPCODE_PORT=8000

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        build-essential \
        libffi-dev \
        python3-dev \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy CPU-friendly requirements
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# Pre-install MCP server packages
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @modelcontextprotocol/server-brave-search @modelcontextprotocol/server-filesystem

# Copy project source code
COPY __init__.py setup.py deepcode.py ./
COPY config/ ./config/
COPY prompts/ ./prompts/
COPY schema/ ./schema/
COPY tools/ ./tools/
COPY utils/ ./utils/
COPY workflows/ ./workflows/
COPY cli/ ./cli/
COPY ui/ ./ui/
COPY new_ui/backend/ ./new_ui/backend/

# Copy frontend build output from Stage 1
COPY --from=frontend-builder /build/dist ./new_ui/frontend/dist

# Create runtime directories
RUN mkdir -p deepcode_lab uploads logs

# Entrypoint
COPY deepcode_docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
