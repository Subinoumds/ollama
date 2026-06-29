#!/usr/bin/env bash
# Pull du modèle d'étude principal.
# Cf. README pour le choix de qwen2.5-coder:3b sur cette machine (8 Go RAM, CPU only).
set -euo pipefail

MODEL="qwen2.5-coder:3b"

echo "Pull du modèle Ollama : $MODEL (~ 1,9 Go)…"
ollama pull "$MODEL"

echo
echo "Catalogue local :"
ollama list
