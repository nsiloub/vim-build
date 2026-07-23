<!--===========================================================
===============================================================
                        VIM-BUILD - Readme
===============================================================
=============================================================-->

Still working on it :) 
# vim-build


A small Vim plugin for CMake-based C++ workflows.

## Features

- Generate a starter C++ CMake project
- Detect and initialize existing CMake projects
- Switch between Debug and Release build modes
- Build, run, clean, and rebuild from Vim
- Toggle the quickfix window
- Compile the current file using `compile_commands.json` when available

## Requirements

- Vim with `:terminal` / `term_start()`
- [vim-dispatch](https://github.com/tpope/vim-dispatch)
- CMake
- Bash
- Python 3

## Installation

Use your preferred plugin manager, or copy the plugin into your Vim runtimepath.

Example with a plugin manager [vim-plug](https://github.com/junegunn/vim-plug) :

```vim
Plug 'nsiloub/vim-build'
```

## Commands

-   ```:GenerateBoilerPlate``` — prompt for a target directory and generate a C++ CMake project skeleton<br>
-   ```:CmakeOn``` — initialize plugin state for the current CMake project<br>
-   ```:SetDebugMode``` — set active build mode to Debug<br>
-   ```:SetReleaseMode``` — set active build mode to Release<br>
-   ```:ShowBuildMode``` — display the current build mode<br>
-   ```:CompileAll``` — build the shared sources target only<br>
-   ```:CompileCurrent``` — build the current file using compile_commands.json when available<br>
-   ```:Build``` — build the current build directory<br>
-   ```:RunCurrent``` — run the current project executable<br>
-   ```:BuildAndRun``` — build and run the current project<br>
-   ```:Clean``` — clean the current build directory<br>
-   ```:Rebuild``` — clean and rebuild the current build directory<br>
-   ```:ToggleQuickFix``` — toggle the quickfix window<br>


## Mappings (Optional)
```vimscript
    <C-b> — toggle quickfix
```

## Command-line abbreviations

-   ```gpb``` → ```:GenerateBoilerPlate```
-   ```con``` → ```:CmakeOn```
-   ```sdm``` → ```:SetDebugMode```
-   ```srm``` → ```:SetReleaseMode```
-   ```sbm``` → ```:ShowBuildMode```
-   ```tqf``` → ```:ToggleQuickFix```


## Usage

\**Important: To make it easy, the cwd (current working directory) of your vim (tab or instance) must be in the parent directory of your project.  
Either by ```vim .```(when you load your project), or inside vim, if you use tabs for example, you can do ```:tcd /path/to/your/project/``` or something similar.


###     Generate a new project
```vim
:GenerateBoilerPlate
```

This creates a starter project and initial build files.

###     Build and run
```vim
:Build
:RunCurrent
:BuildAndRun
```

###     Select build mode
```vim
:SetDebugMode:SetReleaseMode:ShowBuildMode
```

###     Compile actions
```vim
:CompileAll:CompileCurrent
```

###     Clean / rebuild
```vim
:Clean:Rebuild
```

Quickfix
```vim
:ToggleQuickFix
```

Or press:
```vim
<C-b>
```

###     Turn on The building functionalities 

Open Vim in a directory containing ```CMakeLists.txt```, then run:
```vim
:CmakeOn
```
*Note that this is useful for one of these cases:
-   You didn't have the  ```CMakeLists.txt``` when you loaded the folder with vim
-   You had ```CMakeLists.txt``` on the folder but it wasn't your ```cwd``` (current working directory) yet.



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
└── src/
    ├── Headers/
    ├── Sources/
    └── main.cpp
```

###     Notes

-   ```:RunCurrent``` runs the executable from ```bin/{Debug,Release}/<project-name>```.
-   ```:CompileCurrent``` uses ```compile_commands.json``` when it can resolve the current file.
-   The generated CMake project creates a ```mySources``` library target for source files.

