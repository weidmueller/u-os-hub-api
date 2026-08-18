// SPDX-FileCopyrightText: 2026 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
//
// SPDX-License-Identifier: MIT

// Rule: Name every object schema. Client generators must not invent type names.

const SINGLE_SCHEMA_KEYS = [
  'additionalProperties',
  'contains',
  'else',
  'if',
  'items',
  'not',
  'propertyNames',
  'then',
  'unevaluatedItems',
  'unevaluatedProperties',
];

const ARRAY_SCHEMA_KEYS = ['allOf', 'anyOf', 'oneOf', 'prefixItems'];
const MAP_SCHEMA_KEYS = ['$defs', 'definitions', 'dependentSchemas', 'patternProperties', 'properties'];

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function isObjectSchema(schema) {
  return Object.prototype.hasOwnProperty.call(schema, 'properties');
}

// Check schemas nested under schema keywords.
function inspectSchema(schema, path, isNamedComponent, results) {
  if (!isRecord(schema)) return;

  if (!isNamedComponent && !Object.prototype.hasOwnProperty.call(schema, '$ref') && isObjectSchema(schema)) {
    results.push({
      message: 'Inline object schema must be defined in components.schemas and referenced with $ref.',
      path,
    });
  }

  for (const key of SINGLE_SCHEMA_KEYS) {
    if (isRecord(schema[key])) inspectSchema(schema[key], [...path, key], false, results);
  }

  for (const key of ARRAY_SCHEMA_KEYS) {
    if (!Array.isArray(schema[key])) continue;
    const isNamedComposition = isNamedComponent && key === 'allOf';
    schema[key].forEach((child, index) =>
      inspectSchema(child, [...path, key, index], isNamedComposition, results),
    );
  }

  for (const key of MAP_SCHEMA_KEYS) {
    if (!isRecord(schema[key])) continue;
    for (const [name, child] of Object.entries(schema[key])) {
      inspectSchema(child, [...path, key, name], false, results);
    }
  }
}

// Find schemas outside the component registry.
function inspectDocument(node, path, results) {
  if (Array.isArray(node)) {
    node.forEach((child, index) => inspectDocument(child, [...path, index], results));
    return;
  }
  if (!isRecord(node)) return;

  for (const [key, child] of Object.entries(node)) {
    if (path.length === 1 && path[0] === 'components' && key === 'schemas') continue;
    if (key === 'schema') {
      inspectSchema(child, [...path, key], false, results);
    } else {
      inspectDocument(child, [...path, key], results);
    }
  }
}

export default function noAnonymousObjectSchemas(root) {
  const results = [];
  const schemas = root?.components?.schemas;

  // Named components may contain valid allOf parts.
  if (isRecord(schemas)) {
    for (const [name, schema] of Object.entries(schemas)) {
      inspectSchema(schema, ['components', 'schemas', name], true, results);
    }
  }

  inspectDocument(root, [], results);
  return results;
}