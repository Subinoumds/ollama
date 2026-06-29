# Ollama CLI Exploration — Learning Lab

![Status](https://img.shields.io/badge/Status-Completed-success)

**Carnet de manipulation 100 % ligne de commande pour s'auto-former à un serveur d'inférence LLM local (Ollama), dans le cadre du Learning Lab du MBA Développeur Fullstack.**

## Sommaire
- [Pourquoi ce dépôt](#pourquoi-ce-dépôt)
- [Choix méthodologiques](#choix-méthodologiques)
- [Pré-requis matériel](#pré-requis-matériel)
- [Installation](#installation)
- [Modèle utilisé](#modèle-utilisé)
- [Commandes utiles](#commandes-utiles)
- [Tests réalisés](#tests-réalisés)
- [Appel via API HTTP](#appel-via-api-http)
- [Métriques observées](#métriques-observées)
- [Ce que j'en retiens](#ce-que-jen-retiens)
- [Comment rejouer toute la démarche](#comment-rejouer-toute-la-démarche)
- [Limites de cette exploration](#limites-de-cette-exploration)
- [Pour aller plus loin](#pour-aller-plus-loin)

## Pourquoi ce dépôt

Ce dépôt accompagne mon rapport académique dans le cadre du Learning Lab du MBA Développeur Fullstack. Il a été conçu comme un **carnet de manip CLI** reproductible orienté auto-formation. L'objectif est de démystifier le fonctionnement réel d'Ollama : appels HTTP, streaming des tokens, métriques d'inférence (`eval_count`, `eval_duration`, `tokens/s`). Une UI cache la mécanique ; la CLI la rend visible — et donc apprenable.

## Choix méthodologiques

Deux décisions assumées en amont, qui structurent toute l'étude :

**1. 100 % ligne de commande, pas d'Open WebUI.**
Open WebUI est l'interface web de référence pour brancher un client type ChatGPT sur un Ollama local. Elle est très bien, mais elle abstrait justement ce que je veux apprendre. La CLI me force à voir les appels HTTP, les chunks de streaming, les métriques d'inférence — tout ce qui est invisible dans une UI. Open WebUI reste pertinent en phase de généralisation (pour des utilisateurs non-développeurs), pas en phase d'auto-formation.

**2. Un seul modèle, étudié en profondeur (`qwen2.5-coder:3b`).**
Ma machine de travail tourne en CPU pur avec 8 Go de RAM. Sur ce hardware, seuls les modèles compacts (≤ 3B paramètres) sont confortablement utilisables ; faire tourner un 7B donnerait des résultats lents et peu représentatifs d'un usage réel sur ce poste. Plutôt que de simuler un comparatif multi-modèles que je ne peux pas mener honnêtement, j'ai choisi d'aller en profondeur sur un seul modèle bien adapté à la machine : 5 scénarios variés (revue de code, explication, génération de tests, message de commit, investigation de bug), métriques `--verbose` capturées intégralement, notations qualitatives argumentées. Mieux vaut un benchmark étroit et solide qu'un comparatif large et bancal.

## Pré-requis matériel

| Aspect | Cette étude | Recommandation production |
| :--- | :--- | :--- |
| CPU | Suffit (8 Go RAM utilisée) | OK pour 3B |
| GPU | Non utilisé | Recommandé dès qu'on passe à 7B+ |
| Disque | ~ 2 Go pour le modèle | Idem |
| Modèle | qwen2.5-coder:3b (~1,9 Go) | Pour 8-16 Go RAM |

**Machine de test** : `inference compute id=cpu library=cpu`, 8 Go RAM totale, pas d'accélération GPU. Les performances mesurées (~ 9 tok/s) seraient significativement meilleures (facteur ~ 6×) sur un Mac Apple Silicon ou un poste GPU NVIDIA.

## Installation

```bash
# 1. Installer Ollama (script officiel)
curl -fsSL https://ollama.com/install.sh | sh

# 2. Vérifier la version installée
ollama --version
# → ollama version is 0.30.10
```

Note macOS : alternative possible avec Homebrew (`brew install ollama`) ou en téléchargeant le `.pkg` depuis https://ollama.com.

Démarrage du serveur local (utile si on n'utilise pas l'app macOS en arrière-plan) :

```bash
ollama serve
```

## Modèle utilisé

**`qwen2.5-coder:3b`** — modèle spécialisé code, 3 milliards de paramètres, ~ 1,9 Go sur disque, conçu par Alibaba (famille Qwen 2.5). Le choix s'appuie sur trois critères :

- **Compact** : tient confortablement dans 4 à 8 Go de RAM, donc utilisable sur ma machine.
- **Spécialisé code** : entraîné pour la programmation, ce qui le rend pertinent pour les 5 scénarios de l'étude (revue, explication, tests, commit, debug).
- **Licence permissive** (Apache 2.0) : pas de friction légale pour un usage en entreprise.

```bash
ollama pull qwen2.5-coder:3b
```

Sortie attendue :
```
$ ollama list
NAME                   ID            SIZE     MODIFIED
qwen2.5-coder:3b       a1b2c3d4      1.9 GB   1 minute ago
```

## Commandes utiles

| Commande | Explication |
| :--- | :--- |
| `ollama pull <modèle>` | Télécharge un modèle en local. |
| `ollama run <modèle>` | Lance le modèle en mode interactif (REPL). |
| `ollama run --verbose <modèle>` | Lance le modèle et affiche les métriques de perf à la fin. |
| `ollama list` | Liste les modèles installés localement. |
| `ollama ps` | Montre le(s) modèle(s) chargé(s) en mémoire vive. |
| `ollama stop <modèle>` | Décharge un modèle de la mémoire. |
| `ollama show --modelfile <modèle>` | Affiche le Modelfile (prompt système, paramètres). |
| `ollama rm <modèle>` | Supprime le modèle du disque. |

À l'intérieur du REPL, les commandes méta : `/?`, `/show modelfile`, `/clear`, `/bye`.

## Tests réalisés

Cinq scénarios distincts, exécutés sur `qwen2.5-coder:3b`. Chaque scénario a un fichier de prompt (`prompts/`), un fichier d'input (`inputs/`), et un résultat (`results/qwen2.5-coder-3b/`).

### 01. Revue de code
- **Objectif** : Repérer 3 vulnérabilités classiques (SQL injection, `==` au lieu de `bcrypt.compare`, cookie sans `httpOnly`).
- **Prompt** : [prompts/01-code-review.md](prompts/01-code-review.md)
- **Input** : [inputs/01-vulnerable-diff.diff](inputs/01-vulnerable-diff.diff)
- **Commande** :
  ```bash
  cat inputs/01-vulnerable-diff.diff | ollama run --verbose qwen2.5-coder:3b "$(cat prompts/01-code-review.md)"
  ```
- **Résultat** : [results/qwen2.5-coder-3b/01-code-review.md](results/qwen2.5-coder-3b/01-code-review.md) — **note 2/5** (détecte 2 vulnérabilités sur 3, hallucine une XSS absente, contradiction interne sur l'usage de bcrypt).

### 02. Explication de code obscur
- **Objectif** : Comprendre une fonction PHP de Levenshtein avec variables mal nommées.
- **Prompt** : [prompts/02-code-explanation.md](prompts/02-code-explanation.md)
- **Input** : [inputs/02-legacy-php-function.php](inputs/02-legacy-php-function.php)
- **Commande** :
  ```bash
  cat inputs/02-legacy-php-function.php | ollama run --verbose qwen2.5-coder:3b "$(cat prompts/02-code-explanation.md)"
  ```
- **Résultat** : [results/qwen2.5-coder-3b/02-code-explanation.md](results/qwen2.5-coder-3b/02-code-explanation.md) — **note 4/5** (identifie correctement l'algorithme, propose un refactoring lisible).

### 03. Génération de tests unitaires
- **Objectif** : Générer une suite Jest pour `chunk(array, size)`.
- **Prompt** : [prompts/03-unit-tests.md](prompts/03-unit-tests.md)
- **Input** : [inputs/03-utility-to-test.js](inputs/03-utility-to-test.js)
- **Commande** :
  ```bash
  cat inputs/03-utility-to-test.js | ollama run --verbose qwen2.5-coder:3b "$(cat prompts/03-unit-tests.md)"
  ```
- **Résultat** : [results/qwen2.5-coder-3b/03-unit-tests.md](results/qwen2.5-coder-3b/03-unit-tests.md) — **note 3/5** (cas standards couverts, cas limites partiellement manqués).

### 04. Génération de message de commit
- **Objectif** : Extraire le sens d'un diff et rédiger un commit Conventional Commits.
- **Prompt** : [prompts/04-commit-message.md](prompts/04-commit-message.md)
- **Input** : [inputs/04-feature-diff.diff](inputs/04-feature-diff.diff)
- **Commande** :
  ```bash
  cat inputs/04-feature-diff.diff | ollama run --verbose qwen2.5-coder:3b "$(cat prompts/04-commit-message.md)"
  ```
- **Résultat** : [results/qwen2.5-coder-3b/04-commit-message.md](results/qwen2.5-coder-3b/04-commit-message.md) — **note 4/5** (format respecté, légère surinterprétation).

### 05. Investigation de bug
- **Objectif** : Diagnostiquer un `KeyError: 'user_id'` dans Flask.
- **Prompt** : [prompts/05-bug-investigation.md](prompts/05-bug-investigation.md)
- **Input** : [inputs/05-python-stack-trace.txt](inputs/05-python-stack-trace.txt)
- **Commande** :
  ```bash
  cat inputs/05-python-stack-trace.txt | ollama run --verbose qwen2.5-coder:3b "$(cat prompts/05-bug-investigation.md)"
  ```
- **Résultat** : [results/qwen2.5-coder-3b/05-bug-investigation.md](results/qwen2.5-coder-3b/05-bug-investigation.md) — **note 4/5** (diagnostic correct, correction propre avec `functools.wraps`).

**Moyenne sur 5 scénarios : 3,4 / 5.** Hétérogène selon la nature de la tâche : 4/5 sur les tâches narratives (explication, debug, commit), 2/5 sur la sécurité (où le modèle hallucine).

## Appel via API HTTP

Ollama expose deux endpoints. Pratique pour brancher l'app sur un client HTTP standard.

**1. Endpoint natif (`/api/generate`)** :

```bash
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:3b",
  "prompt": "Explique en une phrase le rôle de CORS.",
  "stream": false
}'
```

**2. Endpoint compatible OpenAI (`/v1/chat/completions`)** :

```bash
curl -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder:3b",
    "messages": [
      {"role": "system", "content": "Tu es un assistant tech."},
      {"role": "user", "content": "Que fait un middleware ?"}
    ]
  }'
```

Avantage clé de l'endpoint OpenAI-compatible : on peut brancher n'importe quel SDK conçu pour OpenAI (Python, JS) sur son Ollama local en changeant uniquement l'URL de base. Migration sans réécrire le code applicatif.

## Métriques observées

Mesures réelles extraites des sorties `--verbose` des 5 tests. Machine : CPU-only, 8 Go RAM.

| Test | Total duration | Tokens prompt | Tokens output | Eval rate |
| :--- | :---: | :---: | :---: | :---: |
| 01 — Revue de code | 1 min 5 s | 379 | 500 | 9,51 tok/s |
| 02 — Explication code | 1 min 55 s | 464 | 968 | 9,08 tok/s |
| 03 — Tests unitaires | 27 s | 320 | 206 | 9,50 tok/s |
| 04 — Message commit | 25 s | 300 | 194 | 9,65 tok/s |
| 05 — Investigation bug | 1 min 5 s | 560 | 503 | 9,24 tok/s |
| **Moyenne** | | | | **9,40 tok/s** |

Lecture rapide : sur CPU pur, on est entre 9 et 10 tokens/seconde. Pour un usage interactif (chat), c'est lent mais utilisable (un être humain lit à environ 5 tok/s). Pour un usage batch (CI/CD, scripts de revue automatique), c'est rédhibitoire — il faudrait du GPU.

Pour comparaison : un Mac M1 Pro avec MLX activé tournerait à 50-60 tok/s sur le même modèle, soit ~6× plus rapide. La fenêtre d'usage CPU est utile pour valider une chaîne CLI et apprendre, pas pour de la production.

## Ce que j'en retiens

- **qwen2.5-coder:3b sur CPU est fonctionnel mais lent.** Pour un usage interactif occasionnel, ça passe. Pour intégrer Ollama dans un workflow d'équipe (CI/CD, hook Git), il faut au minimum un GPU modeste.
- **La qualité 3B est inégale selon les tâches.** Explication de code (4/5) et investigation de bug (4/5) sont solides. Revue de sécurité (2/5) est faible — le modèle hallucine. La règle empirique « petit modèle = bien pour les tâches simples, mauvais pour les tâches qui demandent du raisonnement précis » se vérifie.
- **L'eval rate est stable.** Entre 9,08 et 9,65 tok/s sur des prompts de tailles très différentes (de 300 à 560 tokens en input). La performance dépend essentiellement du modèle et du hardware, peu du contenu du prompt.
- **L'écart « bonne machine vs mauvaise machine » est énorme.** Un facteur ~6× entre CPU 8 Go et M1 Pro 16 Go. Une équipe envisageant d'adopter Ollama doit budgéter du matériel adapté, sinon l'outil sera vécu comme une corvée.

## Comment rejouer toute la démarche

```bash
# 1. Cloner le repo
git clone https://github.com/[à compléter]/ollama-cli-exploration.git
cd ollama-cli-exploration

# 2. Installer Ollama (cf. section Installation)
curl -fsSL https://ollama.com/install.sh | sh

# 3. Télécharger le modèle (~ 1,9 Go)
./scripts/pull-models.sh

# 4. Lancer les 5 exécutions de test
./scripts/run-all-tests.sh

# 5. Mesurer la vélocité pure (5 itérations d'un prompt court)
./scripts/benchmark.sh
```

## Limites de cette exploration

- **Un seul modèle testé** (`qwen2.5-coder:3b`). Choix méthodologique assumé pour cause de matériel (cf. § « Choix méthodologiques »), mais limite réelle : la comparaison « petit modèle vs gros modèle » n'a pas été menée empiriquement.
- **Machine CPU-only avec 8 Go de RAM**, non représentative d'un poste de développement standard. Les performances absolues (~ 9 tok/s) ne sont pas extrapolables ; seul l'ordre de grandeur (3B utilisable en interactif sur CPU) l'est.
- **Notation qualitative subjective**, faite par moi sur la base des sorties. Pas de LLM-as-a-judge, pas de panel d'évaluateurs aveuglés. Donne un ordre de grandeur, pas une métrique normalisée.
- **Pas d'évaluation de l'API HTTP en charge.** Les `curl` exemples marchent mais n'ont pas été testés en concurrence ou en streaming.
- **Pas de RAG, pas de fine-tuning, pas d'intégration IDE.** Ces sujets sortent du périmètre temporel.

## Pour aller plus loin

- **Tester des modèles plus grands sur du matériel adapté** : qwen2.5-coder:7b, phi-4-mini, llama3.2:3b pour répondre à la question « est-ce que le saut 3B → 7B vaut le coût matériel ? ».
- **RAG (Retrieval-Augmented Generation)** : indexer la documentation interne d'un projet et brancher Ollama dessus via LangChain ou LlamaIndex.
- **Fine-tuning léger (LoRA)** : entraîner un petit modèle sur le style de code de l'équipe pour gagner en pertinence.
- **Intégration IDE** : Continue.dev dans VS Code, pointé vers le serveur Ollama local ou un Ollama d'équipe partagé.
- **Open WebUI** : déployer une interface graphique pour les utilisateurs non-développeurs (écartée volontairement dans cette étude, mais utile en phase de généralisation).
