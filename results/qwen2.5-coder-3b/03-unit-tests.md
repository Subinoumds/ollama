# Résultat — qwen2.5-coder:3b sur 03-unit-tests

## Commande exécutée
```bash
$ cat inputs/03-utility-to-test.js | ollama run --verbose "qwen2.5-coder:3b" "$(cat prompts/03-unit-tests.md)"
```

## Sortie du modèle

```javascript
const chunk = require('./chunk');

test('chunk([1, 2, 3, 4], 2)', () => {
  expect(chunk([1, 2, 3, 4], 2)).toEqual([[1, 2], [3, 4]]);
});

test('chunk([], 3)', () => {
  expect(chunk([], 3)).toEqual([]);
});

test('chunk([1, 2, 3], 0)', () => {
  expect(chunk([1, 2, 3], 0)).toEqual([]);
});

test('chunk([1, 2, 3, 4], 5)', () => {
  expect(chunk([1, 2, 3, 4], 5)).toEqual([[1, 2, 3, 4]]);
});

test('chunk("hello", 2)', () => {
  expect(() => chunk("hello", 2)).toThrow(new TypeError('Expected an array'
array'));
});
```


## Métriques (extraites de --verbose)
- total duration:       27.335824819s
- load duration:        231.353755ms
- prompt eval count:    320 token(s)
- prompt eval duration: 5.387854s
- prompt eval rate:     59.39 tokens/s
- eval count:           206 token(s)
- eval duration:        21.680076s
- eval rate:            9.50 tokens/s

## Notation qualitative (sur 5)
**Note : 3 / 5**

**Justification :** 5 tests Jest générés, couvrant les cas standards (chunking simple, tableau vide, taille > longueur). Manque les cas limites les plus intéressants : valeurs négatives, types invalides plus variés. La convention de comportement pour `size = 0` (le modèle retourne `[]`) est discutable — un vrai code prod lèverait probablement une erreur. Sortie utilisable mais à compléter.
