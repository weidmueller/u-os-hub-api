#!/usr/bin/env node
function getPathOfSwaggerDist() {
  return require("swagger-ui-dist").getAbsoluteFSPath();
}
process.stdout.write(getPathOfSwaggerDist());
