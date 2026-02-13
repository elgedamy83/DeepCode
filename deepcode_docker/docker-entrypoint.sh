#!/bin/bash
set -e

echo "============================================"
echo "  DeepCode - AI Research Engine (Docker)"
echo "============================================"

# ------ Validate configuration ------
if [ ! -f "mcp_agent.config.yaml" ]; then
    echo "⚠️  mcp_agent.config.yaml not found, using default config"
fi

if [ ! -f "mcp_agent.secrets.yaml" ]; then
    echo ""
    echo "❌ ERROR: mcp_agent.secrets.yaml not found!"
    echo ""
    echo "Please mount your secrets file:"
    echo "  docker run -v ./mcp_agent.secrets.yaml:/app/mcp_agent.secrets.yaml ..."
    echo ""
    echo "Or use docker-compose with the provided template."
    echo ""
    exit 1
fi

# ------ Ensure directories exist ------
mkdir -p deepcode_lab uploads logs deepcode_input generated_app

# ------ BRD → App automation (optional) ------
if [ "$1" = "run_brd" ]; then
    echo ""
    echo "📄 Generating app from BRD input..."
    echo "============================================"
    python cli/main_cli.py --input ./deepcode_input --output ./generated_app
    echo ""
    echo "✅ App generated in ./generated_app"
    exit 0
fi

# ------ CLI mode: launch interactive CLI ------
if [ "$1" = "cli" ]; then
    shift
    echo ""
    echo "🖥️  Starting DeepCode CLI..."
    echo "============================================"
    exec python cli/main_cli.py "$@"
fi

# ------ Web mode (default): start backend + frontend ------
echo ""
echo "🚀 Starting DeepCode Web Backend..."
echo "   API:  http://localhost:${DEEPCODE_PORT:-8000}"
echo "   Docs: http://localhost:${DEEPCODE_PORT:-8000}/docs"
echo "============================================"
exec python -m uvicorn new_ui.backend.main:app \
    --host "${DEEPCODE_HOST:-0.0.0.0}" \
    --port "${DEEPCODE_PORT:-8000}" \
    --workers 1 \
    --log-level info
