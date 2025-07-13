#!/bin/bash
# Ensures all essential agent/AI tools for Python and Go projects are installed locally
# Includes: CrewAI, AutoGen, LangChain, LlamaIndex, OpenAI, HuggingFace, llama.cpp, Ollama, and Go agent tools

set -e

echo "🔍 Checking and installing Python AI/agent libraries..."
PY_PKGS=(crewai pyautogen langchain langgraph llama-index openai huggingface_hub tiktoken)
for pkg in "${PY_PKGS[@]}"; do
  if ! pip show "$pkg" &>/dev/null && ! pipx list | grep -q "$pkg"; then
    echo "📦 Installing $pkg..."
    pip install "$pkg" || pipx install "$pkg"
  else
    echo "✅ $pkg already installed."
  fi
done

echo "🔍 Checking and installing Go agent/AI binaries..."
GO_BINARIES=(github.com/go-skynet/LocalAI/cmd/local-ai github.com/sashabaranov/go-openai)
for bin in "${GO_BINARIES[@]}"; do
  BIN_NAME=$(basename "$bin")
  if ! command -v "$BIN_NAME" &>/dev/null; then
    echo "📦 Installing $bin..."
    go install "$bin"@latest
  else
    echo "✅ $BIN_NAME already installed."
  fi
done

# Check/install Ollama
if ! command -v ollama &>/dev/null; then
  echo "📦 Installing Ollama..."
  brew install --cask ollama
else
  echo "✅ Ollama already installed."
fi

# Check/build llama.cpp
if [ ! -d "$HOME/llama.cpp" ]; then
  echo "📦 Cloning llama.cpp..."
  git clone https://github.com/ggerganov/llama.cpp.git "$HOME/llama.cpp"
  cd "$HOME/llama.cpp" && make
else
  echo "✅ llama.cpp already present."
fi

# CrewAI CLI (if available)
if ! pip show crewai-cli &>/dev/null; then
  pip install crewai-cli || true
fi

echo "🧠 All agent/AI tools are set up for local Python and Go development!"
