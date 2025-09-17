# nim2js

Compile Nim source code to JavaScript in the browser. This repository contains a small Nim wrapper that invokes
Emscripten-built Nim compiler internals.

## Installation

Install with `npm install nim2js`

## Usage

```js
import loadNim2Js from "nim2js";

const nim2js = await loadNim2Js();
console.log(nim2js.nim2js("echo 'Hello from Nim!'"));
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
