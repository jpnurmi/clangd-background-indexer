# clangd background indexer

Background indexer for [clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd).

## [Flutter Engine](https://github.com/flutter/flutter/wiki/Compiling-the-engine)

```sh
$ flutter/tools/gn <opts>
$ ninja -C out/host_debug_unopt
$ ln -s out/host_debug_unopt/compile_commands.json
$ CLANGD=./buildtools/linux-x64/clang/bin/clangd clangd-background-indexer.sh 
Run ./buildtools/linux-x64/clang/bin/clangd (74934)...
Fuchsia clangd version 18.0.0 (https://llvm.googlesource.com/llvm-project 725656bdd885483c39f482a01ea25d67acf39c46)
...
$ PATH="$PWD/buildtools/linux-x64/clang/bin:$PATH" code . # enjoy!
```

## [OpenHarmony](https://gitee.com/openharmony)

```sh
$ ./build.sh <opts>
$ ln -s out/<target>/compile_commands.json
$ CLANGD=./prebuilts/clang/ohos/linux-x86_64/llvm/bin/clangd clangd-background-indexer.sh
Run ./prebuilts/clang/ohos/linux-x86_64/llvm/bin/clangd (82596)...
OHOS (dev) clangd version 15.0.4 (llvm-project 05be96a0332402f1213de4c1dba7e57d5398df59)
...
$ PATH="$PWD/prebuilts/clang/ohos/linux-x86_64/llvm/bin:$PATH" code . # enjoy!
```
