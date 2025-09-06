# MVE for Clangd's inferrence issue

See https://github.com/clangd/clangd/issues/123 ,
and https://github.com/clangd/clangd/issues/2481.

## What is the problem ?

In this MVE, we have a `cmake` project with two C++ executables.

- GOOD: empty `main()` with some `include` directives
  - `target_include_directory("includes/")` -> `#include <foo/xxx>`
  - `foo/A.hpp` includes `foo/B.hpp`, foo/B.hpp includes `foo/C.hpp`
- BAD_INFERRENCE: just an empty `main()`.

### Expected behavior

Since `include` is a `-I` of `GOOD`, but not of `BAD_INFERRENCE`,  
one might expect that it's properly inferred by `GOOD`, not `BAD_INFERRENCE`.

## Steps to reproduce:

- MVE: https://github.com/GuillaumeDua/mve_clangd_inferrence_issue
- (optional) Open with `vscode`, reopen in container
- Build with `cmake`, will also generates `build/compile_commands.json`
- Then either:

### (in `vscode`) open `include/foo/A.hpp`, check `clangd` output

```
I[08:21:27.076] ASTWorker building file /workspaces/mve_clangd_issue/include/foo/A.hpp version 1 with command inferred from /workspaces/mve_clangd_issue/BAD_INFERRENCE.cpp
```

### Run `clangd --check=include/foo/B.hpp`

```
I[08:16:14.922] Ubuntu clangd version 21.1.0 (++20250811123159+6f5c887e557f-1~exp1~20250811123320.21)
I[08:16:14.922] Features: linux+grpc
I[08:16:14.922] PID: 633
I[08:16:14.922] Working directory: /workspaces/mve_clangd_issue
I[08:16:14.922] argv[0]: clangd
I[08:16:14.922] argv[1]: --check=include/foo/B.hpp
I[08:16:14.922] Entering check mode (no LSP server)
I[08:16:14.922] Testing on source file /workspaces/mve_clangd_issue/include/foo/B.hpp
I[08:16:14.923] Loading config file at /workspaces/mve_clangd_issue/.clangd
I[08:16:14.923] Loading compilation database...
I[08:16:14.924] Failed to find compilation database for /workspaces/mve_clangd_issue/include/foo/B.hpp
I[08:16:14.924] Generic fallback command is: [/workspaces/mve_clangd_issue/include/foo] /usr/lib/llvm-21/bin/clang++ --driver-mode=g++ -std=c++23 -ferror-limit=0 -resource-dir=/usr/lib/llvm-21/lib/clang/21 -- /workspaces/mve_clangd_issue/include/foo/B.hpp
I[08:16:14.924] Parsing command...
I[08:16:14.926] internal (cc1) args are: -cc1 -triple aarch64-unknown-linux-gnu -fsyntax-only -disable-free -clear-ast-before-backend -disable-llvm-verifier -discard-value-names -main-file-name B.hpp -mrelocation-model pic -pic-level 2 -pic-is-pie -mframe-pointer=non-leaf -fmath-errno -ffp-contract=on -fno-rounding-math -mconstructor-aliases -funwind-tables=2 -enable-tlsdesc -target-cpu generic -target-feature +v8a -target-feature +fp-armv8 -target-feature +neon -target-abi aapcs -debugger-tuning=gdb -fdebug-compilation-dir=/workspaces/mve_clangd_issue/include/foo -fcoverage-compilation-dir=/workspaces/mve_clangd_issue/include/foo -resource-dir /usr/lib/llvm-21/lib/clang/21 -internal-isystem /usr/lib/gcc/aarch64-linux-gnu/13/../../../../include/c++/13 -internal-isystem /usr/lib/gcc/aarch64-linux-gnu/13/../../../../include/aarch64-linux-gnu/c++/13 -internal-isystem /usr/lib/gcc/aarch64-linux-gnu/13/../../../../include/c++/13/backward -internal-isystem /usr/lib/llvm-21/lib/clang/21/include -internal-isystem /usr/local/include -internal-isystem /usr/lib/gcc/aarch64-linux-gnu/13/../../../../aarch64-linux-gnu/include -internal-externc-isystem /usr/include/aarch64-linux-gnu -internal-externc-isystem /include -internal-externc-isystem /usr/include -std=c++23 -fdeprecated-macro -ferror-limit 0 -fmessage-length=197 -fno-signed-char -fgnuc-version=4.2.1 -fno-implicit-modules -fskip-odr-check-in-gmf -fcxx-exceptions -fexceptions -no-round-trip-args -target-feature +outline-atomics -target-feature -fmv -faddrsig -D__GCC_HAVE_DWARF2_CFI_ASM=1 -x c++-header /workspaces/mve_clangd_issue/include/foo/B.hpp
I[08:16:14.927] Building preamble...
I[08:16:14.943] Built preamble of size 818660 for file /workspaces/mve_clangd_issue/include/foo/B.hpp version null in 0.02 seconds
I[08:16:14.943] Indexing headers...
E[08:16:14.944] [pp_file_not_found] Line 3: 'foo/C.hpp' file not found
I[08:16:14.944] Building AST...
E[08:16:14.956] IncludeCleaner: Failed to get an entry for resolved path '' from include <foo/C.hpp> : No such file or directory
I[08:16:14.958] Indexing AST...
I[08:16:14.958] Building inlay hints
I[08:16:14.958] Building semantic highlighting
I[08:16:14.958] Testing features at each token (may be slow in large files)
I[08:16:14.959] All checks completed, 1 errors
```

## Details

The behavior seems consistant across various contexts:

- Does not depend on the `clangd` nor `clang` version (tried with 18,19,20,21 using `llvm.sh all <version>` on clean `docker` image)
- Does not depend on the order of elements in the `compile_commands.json`
- Does not depend on the order of `add_executable` instruction in the `CMakeLists.txt`

Output of `clangd --version`:

```
Ubuntu clangd version 21.1.0 (++20250811123159+6f5c887e557f-1~exp1~20250811123320.21)
Features: linux+grpc
Platform: aarch64-unknown-linux-gnu
```

Editor/LSP plugin:

- `vscode`

  ```
  Version: 1.100.3 (Universal)
  Commit: 258e40fedc6cb8edf399a463ce3a9d32e7e1f6f3
  Date: 2025-06-02T13:30:54.273Z (3 mos ago)
  Electron: 34.5.1
  ElectronBuildId: 11369351
  Chromium: 132.0.6834.210
  Node.js: 20.19.0
  V8: 13.2.152.41-electron.0
  OS: Darwin arm64 24.6.0
  ```

- `llvm-vs-code-extensions.vscode-clangd` 0.2.0


Operating system:

- Darwin arm64 24.6.0

But reproduced on `Windows` `WSL`, in the provided `docker` container, etc.
