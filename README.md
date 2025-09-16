# nim2js

Compile Nim source code to JavaScript in the browser. This repository contains a small Nim wrapper that invokes
Emscripten-built Nim compiler internals.

## Repository layout

- `nim/` - Nim sources (`nim2js.nim`).
- `pkg/` - Emscripten build outputs: `nim2js.js`, `nim2js.wasm`, and
  `nim2js.data` (preloaded Nim stdlib for in-browser compilation).
- `public/` - Minimal demo site (`index.html`) showing usage.
- `package.json` - npm helper scripts to build and run the demo.

## Quick start

### Prerequisites

- Emscripten SDK and Nim compiler configured if you plan to rebuild the `pkg/` artifacts from
  source (the included `pkg/` artifacts can be used without rebuilding).
- Node.js and `npm` for running the demo server and helper scripts.

### Install dependencies

Run `npm install` to install dependencies.

### Build

To build the Emscripten release artifact (uses `config.nims` flags):

```bash
npm run build
```

or

```bash
npm run build-release
```

For a development/debug build (keeps debug symbols):

```bash
npm run build-dev
```

### Run

Run the demo site locally

```bash
npm run dev
```

The `dev` script copies `public/` and `pkg/` into `dist/`,
and starts a small static server from `dist/`. Open the URL printed by `serve` (usually
`http://localhost:3000`) and try the demo.

## Using the library

The demo `public/index.html` shows how to call the exported function
from JavaScript. After `nim2js.js` has loaded a `Module` object exists
and you can call the exported function `nim2js` with `ccall`:

```js
// Call the exported function and get generated JavaScript as a string
const generatedJs = Module.ccall(
  "nim2js",
  "string",
  ["string"],
  ['echo "Hello from Nim!"']
);
```

`public/index.html` includes a small UI that:

- Lets you edit Nim source in a textarea and compile it in the browser.
- Shows the generated JavaScript output.
- Provides a button to execute the generated JavaScript and capture
  console output in a sandboxed way.

## Programmatic API

- `proc nim2js*(nimCode: cstring): cstring` — C-exported function that
  accepts Nim source code as a C string and returns the generated
  JavaScript as a C string. When calling from JavaScript use
  `Module.ccall('nim2js', 'string', ['string'], [nimSource])`.

## Notes about the build

- The `pkg/` directory contains `nim2js.data`, a preloaded archive of the Nim standard library. This enables the Nim
  compiler to resolve imports when running inside the browser.
- Building the Emscripten artifacts requires Emscripten and Nim
  configured for `-d:emscripten`. See `config.nims` for the flags used
  when `-d:emscripten` is set.

## License

This project is licensed under the MIT license; see the `LICENSE` file.
