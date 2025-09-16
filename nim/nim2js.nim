import os
import compiler/[options, idents, pathutils, modulegraphs, pipelines, platform]
import std/symlinks

when defined(emscripten):
    # Needed for the Nim compiler to work on the "linux" target that emscripten pretends to be.
    createSymlink("/proc/self/exe", "/proc/self/exe")

proc compileNimToJS(sourceFile: string, outFile: string) = 
    ## Compile a Nim source file to JavaScript using Nim's compiler internals.
    ## This function sets up a Nim compilation configuration and runs the compilation pipeline.

    when defined(emscripten):
        # When compiling for Emscripten, use the preloaded lib directory
        let libPath = AbsoluteDir(joinPath(".", "lib"))
    else:
        # Otherwise, use the lib directory from user's Nim installation
        let libPath = AbsoluteDir(joinPath(findExe("nim"), "..", "..", "lib"))

    var conf = newConfigRef()
    conf.projectFull = AbsoluteFile(sourceFile)
    conf.outDir = AbsoluteDir(".")
    conf.outFile = RelativeFile(outFile)
    conf.backend = backendJs
    conf.libpath =  libPath

    setTarget(conf.target, osJS, cpuJS)

    conf.cmd = cmdCompileToJS
    conf.searchPaths.add(libPath)

    let cache = newIdentCache()
    let graph = newModuleGraph(cache, conf)

    setPipeLinePass(graph, JSgenPass)

    compilePipelineProject(graph)

proc nim2js*(nimCode: cstring): cstring {.exportc.} = 
  ## Compile Nim code provided as a string to JavaScript and return the JS code as a string.
  ## This function writes the Nim code to a temporary file, compiles it, and reads back the JS output.
  ## It also ensures cleanup of temporary files in case of compilation failure.

  const inputFile = "input.nim"
  const outputFile = "output.js"
  
  writeFile(inputFile, $nimCode)

  try:
    compileNimToJS(inputFile, outputFile)
  except:
    # Cleanup on failure
    removeFile(outputFile)
    removeFile(inputFile)
    raise
  
  return readFile(outputFile).cstring
