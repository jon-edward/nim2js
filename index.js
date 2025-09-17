import __Nim2JsFactory from "./pkg/nim2js.js";

/**
 * @typedef {Object} Nim2Js
 * @property {(nimCode: string) => string} nim2js - The main function for converting Nim code to JavaScript.
 */

/**
 * Loads the Nim2Js module.
 * @returns {Promise<Nim2Js>} A promise that resolves to the Nim2Js module.
 */
export default async function loadNim2Js() {
  const module = await __Nim2JsFactory();
  return {
    nim2js: module.cwrap("nim2js", "string", ["string"]),
  };
}
