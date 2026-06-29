function chunk(array, size = 1) {
  if (!Array.isArray(array)) {
    throw new TypeError('Expected an array');
  }
  if (size < 1) {
    return [];
  }
  const result = [];
  for (let i = 0; i < array.length; i += size) {
    result.push(array.slice(i, i + size));
  }
  return result;
}

module.exports = chunk;
