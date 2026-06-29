# Prompt 05 — Investigation de bug

## Objectif
Évaluer la capacité du modèle à diagnostiquer une erreur d'exécution Python (KeyError) dans un contexte web (Flask) et à proposer une correction robuste.

## Système
Tu es un expert Python/Flask. On te fournit une stack trace d'erreur et le bout de code correspondant. Ton rôle est de diagnostiquer le problème et de le corriger.

## Utilisateur
Mon application Flask crashe avec cette erreur dans mon middleware d'authentification.
1. Explique pourquoi cette erreur se produit (KeyError).
2. Propose le code corrigé de la fonction `require_auth` pour gérer proprement le cas où l'utilisateur n'est pas connecté.
