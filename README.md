<!--===========================================================
===============================================================
                        VIM-BUILD - Readme
===============================================================
=============================================================-->

Still working on it :) 
# vim-build


# vim-build

A Vim plugin for working with C++ CMake projects.

It provides commands for:

- generating a boilerplate C++ CMake project
- loading an existing CMake project
- switching build mode between Debug and Release
- compiling sources without linking
- building the executable
- running the last built executable
- cleaning and rebuilding
- toggling quickfix

---

## Features

- CMake project bootstrap generator
- Debug / Release build mode support
- Project-aware executable path lookup
- Compile-only commands
- Build-only command
- Build-and-run command
- Clean and rebuild commands
- Quickfix toggle
- Optional command-line abbreviations

---

## Requirements

- Vim with `term_start()` support
- CMake
- A C++ compiler toolchain
- [vim-dispatch](https://github.com/tpope/vim-dispatch) for `Dispatch`
- Bash for the boilerplate generator script

---

## Installation

- Manual installation
Place the plugin in your Vim runtime path, for example:

```txt
~/.vim/
├── plugin/vim-build.vim
├── autoload/vim\_build/core.vim
├── doc/vim-build.txt
└── scripts/cmake-init-cpp.sh
```
Then make sure the script is executable:
```sh
chmod +x scripts/cmake-init-cpp.sh
```

- Using a plugin manager
Example with a plugin manager [vim-plug](https://github.com/junegunn/vim-plug) :

```vim
Plug 'nsiloub/vim-build'

:PlugInstall
```





## Commands

### Project setup

-   ```:GenerateBoilerPlate``` — Prompt for a folder and generate a new C++ CMake project skeleton.

-   ```:CmakeOn``` — initialize plugin state for the current CMake project. 

### Build mode

-   ```:SetDebugMode``` — set active build mode to Debug 
-   ```:SetReleaseMode``` — set active build mode to Release 
-   ```:ShowBuildMode``` — display the current build mode 

### Build commands
-   ```:CompileAll``` — Compile all modified source files in the project, without linking.
-   ```:CompileCurrentFile``` — Compile only the current file, without linking.
-   ```:Build``` — Compile all sources and link the executable, without running it.
-   ```:RunPreviousBuilds``` — Run the previously generated executable for the current build mode.
-   ```:BuildAndRun``` — Compile all sources, link the executable, and run it.
-   ```:Clean``` — clean the current build directory.
-   ```:Rebuild``` — Clean, compile, link, and run the current build mode.
-   ```:ToggleQuickFix``` — toggle the quickfix window.



## Command behavior

**```CompileAll```**

This runs the builds only:

-   no final executable link step
-   useful when you want to check compilation of project sources

**```CompileCurrentFile```**

This tries to use compile_commands.json to compile the current file directly.

If compile commands are unavailable or the file cannot be resolved, it falls back to CompileAll.
**```Build```**

This builds the active build directory:

-   build/Debug for Debug mode
-   build/Release for Release mode

**```RunPreviousBuilds```**

This runs the executable from:

-   bin/Debug/<project-name>
-   bin/Release/<project-name>

depending on the active build mode.  

**```BuildAndRun```**

This performs build first, then runs the executable.  

**```Rebuild```**

This cleans the build tree and then performs the build-and-run flow.

**```:CmakeOn```**
This is only useful in cases where you didn't have a ```CMakelists.txt``` in your working directory when you loaded vim, and don't want to generate boilerplate.  









## Mappings
You can set your own keybindings to the commands as you wish, in your ```.vimrc``` file.  
For example, if you need to bind the ```:ToggleQuickFix``` to ```<C-b>```, you can do the following in your ```.vimrc```
```vim
" Key maps for vim-build
nnoremap <silent> <C-b> :ToggleQuickFix<CR>
```


## Usage

\**Important: To make it easy, the cwd (current working directory) of your vim (tab or instance) must be in the parent directory of your project.  
Either by ```vim .```(when you load your project), or inside vim, if you use tabs for example, you can do ```:tcd /path/to/your/project/``` or something similar.





###     Project layout created by the generator
```text
project/
├── bin/
│   ├── Debug/
│   └── Release/
├── build/
│   ├── Debug/
│   └── Release/
├── config/
├── include/
├── lib/
├── src/
│   ├── Headers/
│   ├── Sources/
│   └── main.cpp
└── CMakeLists.txt
```

###     Notes

-   The generated CMake project creates a ```mySources``` library target for source files.
-   ```src/Sources/__dummy.cpp```
-   ```include/Config.h.in```




## Command-line abbreviations ( Optional )
If you need to set your own command lines abbreviations for the long vim commands, for example: ```gbp``` for ```:GenerateBoilerPlate```; or ```con``` for ```:CmakeOn```, you can make them in your ``plugin/vim-build.vim```. Here are some examples:
```vim
cabbrev <expr> gbp   getcmdtype() ==# ':' && getcmdline() =~# '^gbp\\%(\s\|\$\\)'   ? 'GenerateBoilerPlate' : 'gbp'
cabbrev <expr> con   getcmdtype() ==# ':' && getcmdline() =~# '^con\\%(\s\|\$\\)'   ? 'CmakeOn'             : 'con'
cabbrev <expr> sdm   getcmdtype() ==# ':' && getcmdline() =~# '^sdm\\%(\s\|\$\\)'   ? 'SetDebugMode'        : 'sdm'
cabbrev <expr> srm   getcmdtype() ==# ':' && getcmdline() =~# '^srm\\%(\s\|\$\\)'   ? 'SetReleaseMode'      : 'srm'
cabbrev <expr> sbm   getcmdtype() ==# ':' && getcmdline() =~# '^sbm\\%(\s\|\$\\)'   ? 'ShowBuildMode'       : 'sbm'
cabbrev <expr> cbf   getcmdtype() ==# ':' && getcmdline() =~# '^cbf\\%(\s\|\$\\)'   ? 'CompileCurrentFile'  : 'cbf'
cabbrev <expr> cba   getcmdtype() ==# ':' && getcmdline() =~# '^cba\\%(\s\|\$\\)'   ? 'CompileAll'          : 'cba'
cabbrev <expr> bd    getcmdtype() ==# ':' && getcmdline() =~# '^bd\\%(\s\|\$\\)'    ? 'Build'               : 'bd'
cabbrev <expr> rpb   getcmdtype() ==# ':' && getcmdline() =~# '^rpb\\%(\s\|\$\\)'   ? 'RunPreviousBuilds'   : 'rpb'
cabbrev <expr> bar   getcmdtype() ==# ':' && getcmdline() =~# '^bar\\%(\s\|\$\\)'   ? 'BuildAndRun'         : 'bar'
cabbrev <expr> clb   getcmdtype() ==# ':' && getcmdline() =~# '^clb\\%(\s\|\$\\)'   ? 'CleanBuilds'         : 'clb'
cabbrev <expr> rb    getcmdtype() ==# ':' && getcmdline() =~# '^rb\\%(\s\|\$\\)'    ? 'Rebuild'             : 'rb'
cabbrev <expr> tqf   getcmdtype() ==# ':' && getcmdline() =~# '^tqf\\%(\s\|\$\\)'   ? 'ToggleQuickFix'      : 'tqf'
```

