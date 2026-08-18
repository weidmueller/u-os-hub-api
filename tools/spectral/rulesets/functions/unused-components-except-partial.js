// SPDX-FileCopyrightText: 2026 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
//
// SPDX-License-Identifier: MIT

// Rule: Keep only used schemas, plus matching Partial schemas for generated clients.
// Partial maps use additionalProperties: true to avoid nested optional values.
// Keep Partial types so generated clients still expose type-safe structures.

const PREFIX = 'Partial';

function decodeRef(name) {
  return name.replace(/~1/g, '/').replace(/~0/g, '~');
}

// Collect local schema links.
function collectSchemaRefs(node, out) {
  if (Array.isArray(node)) {
    for (const item of node) collectSchemaRefs(item, out);
  } else if (node && typeof node === 'object') {
    for (const [key, value] of Object.entries(node)) {
      if (key === '$ref' && typeof value === 'string') {
        const match = value.match(/^#\/components\/schemas\/(.+)$/);
        if (match) out.add(decodeRef(match[1]));
      } else {
        collectSchemaRefs(value, out);
      }
    }
  }
}

export default function unusedComponentsExceptPartial(root) {
  const schemas = root && root.components && root.components.schemas;
  if (!schemas || typeof schemas !== 'object' || Array.isArray(schemas)) {
    return [];
  }

  const names = Object.keys(schemas);

  // Start with schemas used by the API.
  const rootRefs = new Set();
  const outside = { ...root, components: { ...root.components, schemas: undefined } };
  collectSchemaRefs(outside, rootRefs);

  // Map links between schemas.
  const edges = new Map();
  for (const name of names) {
    const refs = new Set();
    collectSchemaRefs(schemas[name], refs);
    edges.set(name, refs);
  }

  // Follow all links from used schemas.
  const reachable = new Set();
  const queue = [...rootRefs];
  while (queue.length) {
    const name = queue.shift();
    if (reachable.has(name)) continue;
    reachable.add(name);
    const refs = edges.get(name);
    if (refs) {
      for (const ref of refs) {
        if (!reachable.has(ref)) queue.push(ref);
      }
    }
  }

  const results = [];
  for (const name of names) {
    const hasNonPartialPartner =
      name.startsWith(PREFIX) &&
      Object.prototype.hasOwnProperty.call(schemas, name.slice(PREFIX.length));
    if (reachable.has(name) || hasNonPartialPartner) continue;
    results.push({
      message: `Potentially unused component "#/components/schemas/${name}" is not referenced.`,
      path: ['components', 'schemas', name],
    });
  }
  return results;
}
