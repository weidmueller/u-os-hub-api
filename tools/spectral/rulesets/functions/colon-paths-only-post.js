// SPDX-FileCopyrightText: 2026 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
//
// SPDX-License-Identifier: MIT

// Rule: Define actions as POST operations.

const HTTP_METHODS = ['get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace', 'query'];

export default function colonPathsOnlyPost(pathItem, _options, context) {
  const path = context.path.at(-1);
  if (typeof path !== 'string' || !path.includes(':') || !pathItem || typeof pathItem !== 'object') return [];

  const results = HTTP_METHODS.filter((method) => method !== 'post' && Object.hasOwn(pathItem, method)).map((method) => ({
    message: `Path "${path}" contains a colon and must only use POST operations.`,
    path: [...context.path, method],
  }));

  // No other method means POST itself is missing.
  if (!Object.hasOwn(pathItem, 'post') && results.length === 0) {
    results.push({
      message: `Path "${path}" contains a colon and must define a POST operation.`,
      path: context.path,
    });
  }

  return results;
}