<!--===========================================================
===============================================================
                        TODO:  VIM-BUILD
===============================================================
=============================================================-->

- [x] **Implement a vim command for Debug/Release target**  
    - [x] ``:BuildDebug``:
    - [x] ``:BuildRelease``:
- [ ] **Turn it into a plugin instead**
    - [x]   Restructure into 
        ```bash
        ../vim-build
        ├── autoload
        │   └── vim_build
        │       └── core.vim
        ├── doc
        │   └── vim-build.txt
        ├── plugin
        │   └── vim-build.vim
        ├── scripts
            └── cmake-init-cpp.sh
        ``` 
    - [ ]   
- [ ] **Add vim commands for the currently "key binding only functionalities"**
    - [x]   First change key bindings into vim commands;
        ### Commands that i want:
         - [x]  ```vCompileAll```  Short version ```vca```: Compile all the modified code files in the project, but without linking. ;
         - [x]  ```vCompileCurrent``` Short version ```vcc```: Compile only the current file. ;
         - [x]  ```vBuild``` short version ```vb```: compile, links, produce the executable,  but don't run. ;
         - [x]  ```vRunCurrent``` short version ```vrc```: run the currently existing executable/output. ;
         - [x]  ```vBuildAndRun```. short version ```vbar```: compile, links, produce the executable, and run the executable;
         - [x]  ```vClean``` short ``vc``: removes all cached objects and executables;    
         - [x]  ```vRebuild``` short ```vrb```: does a clean, followed by a build (no run );

    - [x]   Remove the 'V' before the commands and remove short versions
        
         - [x]  ```vCompileAll```  into ==> ```CompileAll```
         - [x]  ```vCompileCurrent``` into ==> ```CompileCurrent```
         - [x]  ```vBuild``` into ==> ```Build```
         - [x]  ```vRunCurrent``` into ==> ```RunCurrent```
         - [x]  ```vBuildAndRun```. into ==> ```BuildAndRun```
         - [x]  ```vClean``` into ==> ```Clean```
         - [x]  ```vRebuild``` into ==> ```Rebuild```
    - [ ]   Add default key bindings to the most important commands(in my private ~/.vimrc);
    - [ ]
    - [ ]
    - [ ]
- [ ] **Resolve problems**
    - [x]  ``:CMakeGenerate``: Generator script not found: /path/to/cmake-cpp-init.sh. And i changed it into ```GenerateBoilerPlate``` 
    - [x]   Not prompting the for project
    - [x]   Not generating correctly, and missing the CMakelists.txt and other
    - [x]   Make vim open a Terminal for the scripts prompts
    - [ ]   
    - [ ]   
    - [ ]   
    - [ ]   
    - [ ]   
    - [ ]   
    - [ ]   
    - [ ]   
    - [ ]   
- [ ] **Implement **
    - [ ]   
    - [ ]   
- [ ] **Implement **
    - [ ]   
    - [ ]   
- [ ] **Implement **
    - [ ]   
    - [ ]   
- [ ] **Implement **
    - [ ]   
    - [ ]   


