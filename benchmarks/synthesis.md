# Synthèse des performances

## Périmètre

Étude focalisée sur **`qwen2.5-coder:3b`**, sur 5 scénarios variés. Choix méthodologique assumé : un modèle adapté à la machine (8 Go RAM, CPU only), étudié en profondeur, plutôt qu'un comparatif multi-modèles que la machine ne permettait pas de mener honnêtement.

## Notation qualitative

Notes sur 5, attribuées sur la base d'une relecture détaillée de chaque sortie, en croisant la qualité technique du résultat et la fidélité au prompt. Détail des justifications dans chaque fichier `results/qwen2.5-coder-3b/0X-*.md`.

| Scénario | Note | Lecture rapide |
| :--- | :---: | :--- |
| 01 — Revue de code (3 vulnérabilités) | **2 / 5** | Détecte 2 vulnérabilités sur 3, hallucine une XSS absente, contradiction interne sur l'usage de bcrypt. |
| 02 — Explication algorithme | **4 / 5** | Identifie correctement Levenshtein, propose un refactoring lisible. |
| 03 — Tests unitaires | **3 / 5** | Cas standards OK, cas limites partiellement manqués. |
| 04 — Message de commit | **4 / 5** | Conventional Commits respecté, légère surinterprétation. |
| 05 — Investigation bug | **4 / 5** | Diagnostic correct, correction propre avec `functools.wraps`. |
| **Moyenne** | **3,4 / 5** | Hétérogène : narrative > sécurité. |

## Performances brutes

Machine : **CPU-only, 8 Go RAM**. Pas de GPU, pas de Metal/MLX. Les chiffres sous-estiment fortement ce qu'on obtiendrait sur Apple Silicon ou GPU NVIDIA (facteur ~ 6× attendu).

| Test | Total | Tokens output | Eval rate |
| :--- | :---: | :---: | :---: |
| 01 — Revue de code | 1 min 5 s | 500 | 9,51 tok/s |
| 02 — Explication code | 1 min 55 s | 968 | 9,08 tok/s |
| 03 — Tests unitaires | 27 s | 206 | 9,50 tok/s |
| 04 — Message commit | 25 s | 194 | 9,65 tok/s |
| 05 — Investigation bug | 1 min 5 s | 503 | 9,24 tok/s |
| **Eval rate moyen** | | | **9,40 tok/s** |

Très bonne stabilité (écart-type ~ 0,2 tok/s). La performance dépend essentiellement du couple modèle/hardware, peu du contenu du prompt.

## Ce que j'en retiens

- **9 tok/s sur CPU pour un 3B est utilisable en interactif mais marginal en automatisé.** Au-delà du POC, prévoir du GPU.
- **Notation hétérogène selon la tâche** : tâches « narratives » (explication, debug, commit) ≥ 4/5, tâche « sécurité » (revue) = 2/5 avec hallucinations. Confirme la règle qu'un petit modèle est faible sur tout ce qui demande du raisonnement précis.
- **Le saut 3B → 7B est une question ouverte sur ce périmètre.** Pour y répondre, il faudrait un hardware capable de faire tourner le 7B confortablement. C'est la suite naturelle de l'étude.
