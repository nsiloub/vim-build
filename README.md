<!--===========================================================
===============================================================
                        VIM-BUILD - Readme
===============================================================
=============================================================-->

Still working on it :) 
# Usage
# vim-build

A small Vim build helper for CMake C++ projects with Debug/Release mode switching.

## Commands & Key Bindings

# vim-build Commands and Key Bindings

## Commands

### Project setup
- `:GenerateBoilerPlate`
- `:gpb`
- `:CmakeOn`
- `:con`

### Build mode
- `:SetDebugMode`
- `:sdm`
- `:SetReleaseMode`
- `:srm`
- `:ShowBuildMode`
- `:sbm`

### Build / run
- `:VCompileAll`
- `:vca`
- `:VCompileCurrent`
- `:vcc`
- `:VBuild`
- `:vb`
- `:VRunCurrent`
- `:vrc`
- `:VBuildAndRun`
- `:vbar`
- `:VClean`
- `:vc`
- `:VRebuild`
- `:vrb`

### Quickfix
- `:ToggleQuickFix`
- `:tqf`

## Key Bindings

- `<C-b>` → toggle quickfix window

## Default Mode

The default build mode is:

- ``Debug``

You can switch it with:

```vim
:BuildDebug
:BuildRelease
```
