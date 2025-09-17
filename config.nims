import os

let compilerRootPath = joinPath(findExe("nim"), "..", "..")

switch("path", compilerRootPath)  # For compiler modules

if defined(emscripten):
    # Taken from https://github.com/treeform/nim_emscripten_tutorial

    # This path will only run if -d:emscripten is passed to nim.

    --os:linux # Emscripten pretends to be linux.
    --cpu:wasm32 # Emscripten is 32bits.
    --cc:clang # Emscripten is very close to clang, so we'll replace it.
    
    when defined(windows):
        --clang.exe:emcc.bat  # Replace C
        --clang.linkerexe:emcc.bat # Replace C linker
        --clang.cpp.exe:emcc.bat # Replace C++
        --clang.cpp.linkerexe:emcc.bat # Replace C++ linker.
    else:
        --clang.exe:emcc  # Replace C
        --clang.linkerexe:emcc # Replace C linker
        --clang.cpp.exe:emcc # Replace C++
        --clang.cpp.linkerexe:emcc # Replace C++ linker.
    
    when compileOption("threads"):
        # We can have a pool size to populate and be available on page run
        # --passL:"-sPTHREAD_POOL_SIZE=2"
        discard

    --listCmd # List what commands we are running so that we can debug them.

    --gc:arc # GC:arc is friendlier with crazy platforms.
    --exceptions:goto # Goto exceptions are friendlier with crazy platforms.
    --define:noSignalHandler # Emscripten doesn't support signal handlers.

    let embeddedLibPath = joinPath(compilerRootPath, "lib") & "@/lib"

    mkDir("pkg")

    switch("passL", "-o ./pkg/nim2js.js")
    switch("passL", "-s MODULARIZE=1 -s EXPORT_ES6=1")
    switch("passL", "-s EXPORT_NAME='__Nim2JsFactory'")
    switch("passL", "-s EXPORTED_FUNCTIONS=['_nim2js','_main']")
    switch("passL", "-s EXPORTED_RUNTIME_METHODS=['ccall','cwrap']")
    switch("passL", "-s TOTAL_STACK=128MB -s TOTAL_MEMORY=256MB")
    switch("passL", "--embed-file " & embeddedLibPath)

    when defined(release):
        # Turn off checks and optimize for size in release mode
        --opt:size
        --checks:off
        --debugger:off
        switch("passL", "-O3 -g0")
    when defined(debug):
        switch("passL", "-O0 -g")
