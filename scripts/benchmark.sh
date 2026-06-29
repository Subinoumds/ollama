#!/usr/bin/env bash
# Benchmark de performance pure (eval rate moyen sur un prompt court).
# Boucle 5× pour stabiliser la mesure et calcule la moyenne.
set -euo pipefail

MODEL="qwen2.5-coder:3b"
PROMPT="Explique le théorème de Pythagore en une phrase."
ITERATIONS=5

echo "Benchmark : $MODEL ($ITERATIONS itérations)"

total_rate=0
for i in $(seq 1 $ITERATIONS); do
  tmp_err=$(mktemp)
  ollama run --verbose "$MODEL" "$PROMPT" > /dev/null 2> "$tmp_err" || true
  rate=$(grep "eval rate:" "$tmp_err" | awk '{print $3}')
  if [ -n "$rate" ]; then
    total_rate=$(awk "BEGIN {print $total_rate + $rate}")
    echo "  itération $i : $rate tokens/s"
  fi
  rm "$tmp_err"
done

avg_rate=$(awk "BEGIN {print $total_rate / $ITERATIONS}")
echo "Eval rate moyen : $avg_rate tokens/s"
