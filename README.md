# uc-hub-api

uc-hub-api contains the flatbuffers messages and types used in uc-hub.
The repository is integrated into uc-hub as a submodule.

## Maintainers

This project is currently maintained by:

- Etienne Schmidt (w011279)
- Christian Peters (w011238)

Please contact the persons above for merge requests or any questions regarding this repository.

## Compile flatbuffers

Flatbuffers schema are compiled into target source code via the flatc compiler.
For an example, see the uc-hub repository.

## Installation

Install `Remote Development` and `Remote-Containers` in Visual Studio Code and start the developing environment via `Reopen in Container`.

## Build

The developing environment installs the project's npm dependencies and executes a build command on startup.
[Run on Save](https://marketplace.visualstudio.com/items?itemName=pucelle.run-on-save) automatically executes a build command when the asyncapi.yaml or openapi.yaml are saved.

```
npm ci --ignore-optional --silent
npm run build
```

## Live Server

Click on `Go Live` from the status bar to turn a [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) on/off and open a live view in the browser.

## Mock HTTP API

We implemented a mock HTTP API for testing the swagger ui and external clients. It is implemented in directory `mock-http-api` using [NestJs](https://nestjs.com/). Install dependencies using

```
npm ci
```

Start the mock using

```
npm run start:dev
```
