/// <reference types="emscripten" />

import Nim2JsFactory from "./pkg/nim2js.js";
import type { MainModule } from "./pkg/nim2js.js";

type Nim2JsModuleType = MainModule & EmscriptenModule & { FS: typeof FS };

export const ROOT_DIR = "/root";

export const TMP_NIM_INPUT = "/tmp/input.nim";
export const TMP_JS_OUTPUT = "/tmp/output.js";

/**
 * Base class for errors thrown by the Nim to JavaScript compiler.
 */
export class Nim2JsError extends Error {}

export type LoadedNim2JsType = {
  /**
   * Run the Nim to JavaScript compiler on a source file, outputting to the specified file.
   */
  runJsCompiler: (sourceFile: string, outFile: string) => void;

  /**
   * Compile Nim source code to JavaScript.
   * Throws a `Nim2JsError` if compilation fails, otherwise returns the compiled JavaScript code.
   */
  nim2js: (source: string) => string;

  /**
   * The Nim2JS Emscripten module.
   */
  module: Nim2JsModuleType;
};

/**
 * Loads the Nim to JavaScript compiler module and sets up the filesystem.
 */
export default async function loadNim2Js(
  moduleOptions: Record<string, unknown>
): Promise<LoadedNim2JsType> {
  const module = (await Nim2JsFactory(moduleOptions)) as Nim2JsModuleType;

  module.FS.mkdirTree(ROOT_DIR);
  module.FS.chdir(ROOT_DIR);

  const runJsCompiler = module.cwrap("runJsCompiler", "void", [
    "string",
    "string",
  ]) as (sourceFile: string, outFile: string) => void;

  function nim2js(source: string): string {
    module.FS.writeFile(TMP_NIM_INPUT, source);
    runJsCompiler(TMP_NIM_INPUT, TMP_JS_OUTPUT);
    return module.FS.readFile(TMP_JS_OUTPUT, { encoding: "utf8" });
  }

  return {
    runJsCompiler,
    nim2js,
    module,
  };
}
