#!/bin/bash

set -euo pipefail
set -x

#Install dependencies
npm ci

#Audit dependencies
npm audit --audit-level=high --omit=dev

#Run build and linters
npm run build