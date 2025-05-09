<!--
SPDX-FileCopyrightText: 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>

SPDX-License-Identifier: MIT
-->

# u-os-hub-api

u-os-hub-api contains API specifications for the u-OS Data Hub.

The u-OS Data Hub provides a standardized way of communicating variable data in u-OS.
This repository contains the following specifications to interact with the variable APIs of the u-OS Data Hub.

- AsyncAPI specification for the Variable-NATS-API
- OpenAPI specification for the Variable-HTTP-API

## AsyncAPI specification for the Variable-NATS-API

The Variable-NATS-API offers a high performance mechanism for both providing and consuming variables within the u-OS Data Hub based on [NATS](https://nats.io/).

[AsyncAPI](https://www.asyncapi.com/en) is a standard to define interfaces of asynchronous APIs.
We use AsyncAPI to specify the events and messages of the Variable-NATS-API in the file `variable-nats-asyncapi.yaml`.

We use [FlatBuffers](https://flatbuffers.dev/) for data serialization.
Find the FlatBuffers messages and types used in the Variable-NATS-API in the directory `flatbuffers`.

## OpenAPI specification for the Variable-HTTP-API

The Variable-HTTP-API is a JSON-based HTTP API for reading and writing variables on the u-OS Data Hub. The focus is on standards and well-known technologies.

We use [OpenAPI](https://swagger.io/specification/) to describe the Variable-HTTP-API in the file `variable-http-openapi.yaml`.

## Developing in Visual Studio Code

Install `Remote Development` and `Remote-Containers` and start the development container via `Reopen in Container`.

The development container installs the project's npm dependencies and executes a build command on startup.
[Run on Save](https://marketplace.visualstudio.com/items?itemName=pucelle.run-on-save) automatically executes a build command when the variable-nats-asyncapi.yaml or variable-http-openapi.yaml are saved.

You can open the OpenAPI UI and the AsyncAPI UI in the browser via the [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension by clicking on `Go Live`.

### Installing dependencies

Execute

```
npm ci --ignore-optional
```

to install necessary dependencies.

### Building

Execute

```
npm run build
```

to perform a complete build of u-os-hub-api.
This includes the following steps:

1.  Generate JSON schemas from the FlatBuffers messages.
    They are used in the generation of the AsyncAPI site.
2.  Validate AsyncAPI using [Spectral](https://stoplight.io/open-source/spectral). See [API validation](#api-validation) for details.
3.  Generate AsyncAPI UI. See [Generate AsyncAPI UI](#generate-asyncapi-ui) for details.
4.  Validate OpenAPI using [Spectral](https://stoplight.io/open-source/spectral). See [API validation](#api-validation) for details.
5.  Generate OpenAPI UI (formerly known as Swagger UI). See [Generate OpenAPI UI](#generate-openapi-ui-swagger-ui) for details.

#### Generating AsyncAPI UI

Execute

```
npm run generateAsyncApiSite
```

to generate the an AsyncAPI UI from `variable-nats-asyncapi.yaml`.

Find the generated UI in directory `dist/asyncapi`.

#### Generating OpenAPI UI (Swagger UI)

Execute

```
npm run generateOpenApiSite
```

to generate the an OpenAPI UI from `variable-http-openapi.yaml`.

Find the generated UI in directory `dist/openapi`.

### Validating the APIs

[Spectral](https://stoplight.io/open-source/spectral) is an API style guide enforcer and linter.

We use Spectral for both OpenAPI and AsyncAPI linting based on a set of rules described in `tools/spectral.json`.

### Compiling FlatBuffers schemata

FlatBuffers schemata are compiled into target source code via the `flatc` compiler.
Flatc is not included in this repository, but can be downloaded from [here](https://github.com/google/flatbuffers/releases).
For an example how to use flatc, see the [Flatbuffers documentation](https://flatbuffers.dev/flatc/).
