import std/os
import compiler/[options, idents, pathutils, modulegraphs, pipelines, platform, condsyms, lineinfos]

when defined(emscripten):
    # Needed for the Nim compiler to work on the "linux" target that emscripten pretends to be.
    createSymlink("/proc/self/exe", "/proc/self/exe")

# # For debugging: get all files in a directory
# import std/algorithm
# proc allFilesInDir(dir: string): seq[string] = 
#     for path in walkDirRec(dir):
#         result.add(path)
#     result.sort()

# # For debugging: print all files in the filesystem
# proc printAllFilesInDir*(dir: cstring) {.exportc.} = 
#     for path in allFilesInDir($dir):
#         echo path

proc runJsCompiler*(sourceFile: cstring, outFile: cstring): cint {.exportc.} = 
    ## Compile a Nim source file to JavaScript using Nim's compiler internals.
    ## This function sets up a Nim compilation configuration and runs the compilation pipeline.
    ## 
    ## Parameters:
    ##   - sourceFile: The path to the Nim source file to compile.
    ##   - outFile: The path where the compiled JavaScript file will be saved.
    
    when defined(emscripten):
        # When compiling for Emscripten, use the preloaded lib directory
        let libPath = AbsoluteDir("/usr/lib/nim/lib")
    else:
        # Otherwise, use the lib directory from user's Nim installation
        let libPath = AbsoluteDir(joinPath(findExe("nim"), "..", "..", "lib"))
    
    var outDir = "."
    var outFileStr = $outFile

    if outFileStr.isAbsolute():
        (outDir, outFileStr) = splitPath(outFileStr)

    var conf = newConfigRef()
    conf.projectFull = AbsoluteFile($sourceFile)
    conf.outDir = AbsoluteDir(outDir)
    conf.outFile = RelativeFile(outFileStr)
    conf.backend = backendJs
    conf.libpath =  libPath

    # Turn off "......" processing hints
    excl(conf.notes, hintProcessing)
    excl(conf.mainPackageNotes, hintProcessing)

    setTarget(conf.target, osJS, cpuJS)

    conf.cmd = cmdCompileToJS
    conf.searchPaths.add(libPath)

    initDefines(conf.symbols)

    let cache = newIdentCache()
    let graph = newModuleGraph(cache, conf)

    setPipeLinePass(graph, JSgenPass)

    compilePipelineProject(graph)
