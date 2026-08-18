// SPDX-FileCopyrightText: 2026 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
//
// SPDX-License-Identifier: MIT

// Rule: GET and PUT use the same schema. Generated clients need no conversion.

// Compare deeply. Ignore object key order.
function schemasEqual(left, right) {
  if (left === right) return true;
  if (!left || !right || typeof left !== 'object' || typeof right !== 'object') return false;
  if (Array.isArray(left) || Array.isArray(right)) {
    if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false;
    return left.every((value, index) => schemasEqual(value, right[index]));
  }

  const leftKeys = Object.keys(left).sort();
  const rightKeys = Object.keys(right).sort();
  if (!schemasEqual(leftKeys, rightKeys)) return false;
  return leftKeys.every((key) => schemasEqual(left[key], right[key]));
}

export default function getPutSameSchema(pathItem, _options, context) {
  // GET output must match PUT input.
  const getSchema = pathItem?.get?.responses?.['200']?.content?.['application/json']?.schema;
  const putSchema = pathItem?.put?.requestBody?.content?.['application/json']?.schema;
  if (!getSchema || !putSchema || schemasEqual(getSchema, putSchema)) return [];

  return [
    {
      message: 'GET response and PUT request body use different schemas on the same path.',
      path: [...context.path, 'put', 'requestBody', 'content', 'application/json', 'schema'],
    },
  ];
}