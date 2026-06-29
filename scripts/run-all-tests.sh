#!/usr/bin/env bash
# Exécute les 5 scénarios de test sur le modèle d'étude (qwen2.5-coder:3b).
# Génère les fichiers Markdown sous results/qwen2.5-coder-3b/
# Archive les sorties --verbose brutes sous benchmarks/raw-verbose-outputs.txt
set -euo pipefail

MODEL="qwen2.5-coder:3b"

PROMPTS=(
  "01-code-review.md"
  "02-code-explanation.md"
  "03-unit-tests.md"
  "04-commit-message.md"
  "05-bug-investigation.md"
)

INPUTS=(
  "01-vulnerable-diff.diff"
  "02-legacy-php-function.php"
  "03-utility-to-test.js"
  "04-feature-diff.diff"
  "05-python-stack-trace.txt"
)

BENCHMARK_FILE="benchmarks/raw-verbose-outputs.txt"
mkdir -p benchmarks "results/${MODEL//:/-}"
> "$BENCHMARK_FILE"

run_test() {
  local prompt_file=$1
  local input_file=$2
  local scenario_name=$(basename "$prompt_file" .md)
  local result_file="results/${MODEL//:/-}/${scenario_name}.md"

  echo "Exécution : $MODEL sur $scenario_name..."

  local prompt_content=$(cat "prompts/$prompt_file")
  local tmp_out=$(mktemp)
  local tmp_err=$(mktemp)

  cat "inputs/$input_file" | ollama run --verbose "$MODEL" "$prompt_content" \
    > "$tmp_out" 2> "$tmp_err" || echo "Erreur d'exécution" >> "$tmp_out"

  cat <<END > "$result_file"
# Résultat — $MODEL sur $scenario_name

## Commande exécutée
\`\`\`bash
\$ cat inputs/$input_file | ollama run --verbose "$MODEL" "\$(cat prompts/$prompt_file)"
\`\`\`

## Sortie du modèle

END
  cat "$tmp_out" >> "$result_file"

  echo -e "\n## Métriques (extraites de --verbose)" >> "$result_file"
  grep -E "duration:|rate:|count:" "$tmp_err" | sed 's/^/- /' >> "$result_file" || true

  echo -e "\n## Notation qualitative (sur 5)\n**Note : TODO / 5**\n\n**Justification :** TODO" >> "$result_file"

  echo "===== modèle $MODEL | scénario $scenario_name =====" >> "$BENCHMARK_FILE"
  cat "$tmp_err" >> "$BENCHMARK_FILE"
  echo "" >> "$BENCHMARK_FILE"

  rm "$tmp_out" "$tmp_err"
}

for i in "${!PROMPTS[@]}"; do
  run_test "${PROMPTS[$i]}" "${INPUTS[$i]}"
done

echo "Tests terminés ! Voir results/${MODEL//:/-}/ et benchmarks/raw-verbose-outputs.txt"
