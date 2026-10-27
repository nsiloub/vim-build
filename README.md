<!--===========================================================
===============================================================
                        VIM-BUILD - Readme
===============================================================
=============================================================-->



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
- turning the vim-build functionalities on and off

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

-   ```:CmakeOff``` — Turn the vim-build functionalities off, except for ```VimBuildState```, ```GenerateBoilerPlate```, and ```CmakeOn```.

-   ```:VimBuildState```— Shows the state of vim-build features.


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
-   ```:ShowOutputs``` — Shows the output of the run/build commands in a quickfix-like window. Note: it can't be ```:copen``` nor ```:cclose```, so use ```:q``` 




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
For example, if you need to bind the ```:ToggleQuickFix``` to ```<C-m>```, you can do the following in your ```.vimrc```  
Here are some default bindings i've set in ```~/.vim/plugged/vim-build/plugin/vim-build.vim```
```vim
" Key maps for vim-build
nnoremap <silent> <C-m> :ToggleQuickFix<CR>
nnoremap <silent> <C-b> :BuildAndRun<CR>
nnoremap <silent> <C-b>c :CleanBuilds<CR>
nnoremap <silent> <C-b>s :ShowOutputs<CR>
```
Make sure to change them as you like.


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
├── data/
├── include/
├── libs/
├── src/
│   ├── Headers/
│   ├── Sources/
│   └── main.cpp
└── CMakeLists.txt
```
*   ***bin/***: Folder for containing the binaries of the built project
*   ***build/***: Folder for containing the generated build files
*   ***config/***: Folder for containing the configuration files
*   ***data/***: Folder for non-code resources your application needs at runtime, such as images, fonts, configuration files, or 3D models.
*   ***include/***: Folder for header files (**.h** or **.hpp**).
*   ***libs/***: Folder for external libraries including the source codes and/or pre-compiled library files (**.a**, **.lib**, **.so**, **.dll**) 
*   ***src/***: Folder for local source files (**.cpp**) and local  header files (**.h** or **.hpp**).
*   ***CMakeLists.txt/***: The main cmake file that contains the overall configurations of your project.

##     Notes

-   The generated CMake project creates a ```mySources``` library target for source files.
-   ```src/Sources/__dummy.cpp```
-   ```include/Config.h.in```



### VimBuildState

`vim-build` is off by default.

#### Available when off
- `:VimBuildState`
- `:GenerateBoilerPlate`
- `:CmakeOn`

#### How it turns on
`vim-build` becomes active only in these cases:

1. You open a folder or file from the terminal, and that location contains a `CMakeLists.txt`, then accept the prompt.
2. You change Vim’s current working directory to a folder containing a `CMakeLists.txt`, then accept the prompt.
3. You run `:CmakeOn` inside Vim.
4. You run `:GenerateBoilerPlate`, which enables `vim-build` if needed.

#### When already on
If `VimBuildState` is already `on`, running `:CmakeOn` will simply report that it is already enabled.

#### When on
All `vim-build` commands become available, including:
- `:CmakeOff`
- build and run commands
- debug/release mode commands
- quickfix toggle

#### Quickfix window pop up tips
If you don't want the quickfix window to pop up automatically after an operation (you want it to run only in background), add a bang (!)  after the Dispatch! in the file ```~/.vim/autoload/vim_build/core.vim``` For example:
    execute 'Dispatch! cmake --build ' . fnameescape(s:build_dir()) . ' --target mySources'
    In That case you'll need to run :Copen manually  
<br>

For interactivity in the editor. This requires a vim with
a ***term_start()*** support. This could be checked with
```:echo has('terminal')```. If 1=> has it; 0=> doesn't




### Command-line abbreviations ( Optional )
If you need to set your own command lines abbreviations for the long vim commands, for example: ```gbp``` for ```:GenerateBoilerPlate```; or ```con``` for ```:CmakeOn```, you can make them in your ```plugin/vim-build.vim```. Here are some examples:
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

