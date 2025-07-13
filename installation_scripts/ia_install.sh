#!/bin/bash

set -e

echo "🚀 Starting DevOps + AI Toolkit setup on macOS..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
  echo "🚨 Homebrew is not installed. Please install it first: https://brew.sh"
  exit 1
fi

# === Cursor IDE ===
echo "🧠 Installing Cursor IDE — AI-powered code editor based on VS Code"
if [ -d "/Applications/Cursor.app" ]; then
  echo "✅ Cursor is already installed. Skipping..."
else
  brew install --cask cursor
fi

# === Visual Studio Code (optional) ===
echo "💻 Installing Visual Studio Code — Traditional IDE with Copilot support"
if [ -d "/Applications/Visual Studio Code.app" ]; then
  echo "✅ VS Code is already installed. Skipping..."
else
  brew install --cask visual-studio-code
fi

# === VS Code extensions ===
echo "🔌 Installing useful VS Code extensions: Python, Copilot, Docker"
if command -v code &> /dev/null; then
  code --install-extension ms-python.python || echo "🔁 Extension ms-python.python already installed"
  code --install-extension GitHub.copilot || echo "🔁 Extension GitHub.copilot already installed"
  code --install-extension GitHub.copilot-chat || echo "🔁 Extension GitHub.copilot-chat already installed"
  code --install-extension ms-azuretools.vscode-docker || echo "🔁 Extension ms-azuretools.vscode-docker already installed"
else
  echo "⚠️ VS Code CLI not available. Run 'Shell Command: Install code in PATH' from VS Code."
fi

# === bun (JS runtime) ===
echo "⚡ Installing Bun — JavaScript runtime & package manager for fast tooling"
if ! command -v bun &> /dev/null; then
  if brew info bun &>/dev/null; then
    brew install bun
  else
    echo "📦 bun formula not available in core — tapping oven-sh/bun..."
    brew tap oven-sh/bun
    brew install bun
  fi
else
  echo "✅ bun is already installed. Skipping..."
fi

# === Python AI libraries using uv ===
echo "📚 Installing AI libraries with uv — LangChain, LangGraph, LlamaIndex, OpenAI..."
uv pip install \
  openai \
  langchain \
  langgraph \
  llama-index \
  huggingface_hub \
  tiktoken \
  pydantic \
  typer \
  rich

# === llama.cpp (local LLMs) ===
echo "🧠 Setting up llama.cpp — run LLMs like LLaMA/Mistral locally on your Mac"
cd ~
if [ -d "llama.cpp" ]; then
  echo "✅ llama.cpp already exists. Pulling latest updates..."
  cd llama.cpp
  git pull
else
  git clone https://github.com/ggerganov/llama.cpp.git
  cd llama.cpp
fi

echo "🔨 Building llama.cpp binaries..."
make
mkdir -p models
echo "📁 Download GGUF models from https://huggingface.co/TheBloke and place them in ~/llama.cpp/models"

# ✅ Final message
echo "✅ DevOps + AI environment is ready!"
echo ""
echo "🛠 Tools installed:"
echo "  - Cursor IDE (AI-based programming)"
echo "  - LangChain, LangGraph, LlamaIndex (AI libraries)"
echo "  - Copilot CLI and bun (CLI and JS tooling)"
echo "  - llama.cpp (local inference of LLMs)"
echo ""
echo "👉 Next step: Start building your AI-assisted DevOps CLI tools!"

