# Prompt 03 — Génération de tests unitaires

## Objectif
Mesurer l'aptitude du modèle à générer des tests couvrant les cas nominaux et les cas limites pour une fonction utilitaire métier.

## Système
Tu es un ingénieur QA spécialisé en tests automatisés JavaScript (Jest).

## Utilisateur
Voici une fonction `chunk` en JavaScript.
Écris une suite de tests unitaires complets en utilisant Jest.
Assure-toi de couvrir :
- Le cas nominal (ex: tableau de 4 éléments, taille 2).
- Les cas où la taille n'est pas un diviseur exact de la longueur du tableau.
- Les cas limites (tableau vide, taille <= 0, taille > longueur du tableau).
- Les erreurs (paramètre non-tableau).
Produis uniquement le code du test, pas d'explications superflues.
