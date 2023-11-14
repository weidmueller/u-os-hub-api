#!/usr/bin/env node

// SPDX-FileCopyrightText: 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
//
// SPDX-License-Identifier: CC0-1.0

function getPathOfSwaggerDist() {
  return require("swagger-ui-dist").getAbsoluteFSPath();
}
process.stdout.write(getPathOfSwaggerDist());
