"=============================================================================
" AUTOLOAD: VIM-BUILD
"=============================================================================


let s:plugin_dir = fnamemodify(expand('<sfile>:p'), ':h:h:h')

function! vim_build#core#toggle_quickfix() abort
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    copen
    cbottom
  else
    cclose
  endif
endfunction

function! s:is_cmake_project(dir) abort
  return filereadable(a:dir . '/CMakeLists.txt')
endfunction

function! s:get_project_dir() abort
  if len(v:argv) == 1
    let l:arg = v:argv[0]
    if l:arg ==# '.'
      return getcwd()
    endif
    return fnamemodify(expand(l:arg), ':p')
  endif
  return getcwd()
endfunction

function! vim_build#core#get_build_mode() abort
  return get(g:, 'cpp_build_mode', 'Debug')
endfunction

function! vim_build#core#set_build_mode(mode) abort
  if a:mode !=# 'Debug' && a:mode !=# 'Release'
    echo "Invalid build mode: " . a:mode
    return
  endif
  let g:cpp_build_mode = a:mode
  echo "Build mode set to: " . a:mode
endfunction

function! s:project_name() abort
  return get(g:, 'cpp_project_name', fnamemodify(getcwd(), ':t'))
endfunction

function! s:build_dir() abort
  return 'build/' . vim_build#core#get_build_mode()
endfunction

function! s:exe_path() abort
  return getcwd() . '/bin/' . vim_build#core#get_build_mode() . '/' . s:project_name()
endfunction

function! s:compile_commands_file() abort
  return getcwd() . '/build/' . vim_build#core#get_build_mode() . '/compile_commands.json'
endfunction

function! s:current_file() abort
  return expand('%:p')
endfunction

function! s:run_shell(cmd) abort
  execute 'Dispatch! sh -c ' . shellescape(a:cmd)
endfunction

function! vim_build#core#compile_all() abort
  " Compiles the project sources without linking the final executable.
  execute 'Dispatch! cmake --build ' . fnameescape(s:build_dir()) . ' --target mySources'
endfunction

function! vim_build#core#compile_current() abort
  let l:file = s:current_file()
  if empty(l:file)
    echo "No current file"
    return
  endif

  let l:cc = s:compile_commands_file()
  if filereadable(l:cc)
    let l:cmd = 'python3 - <<''PY''
import json, os, shlex, subprocess, sys
cc = sys.argv[1]
src = os.path.abspath(sys.argv[2])
with open(cc, "r", encoding="utf-8") as f:
    data = json.load(f)
for entry in data:
    if os.path.abspath(entry.get("file", "")) == src:
        cmd = entry["command"] if "command" in entry else " ".join(entry["arguments"])
        print(cmd)
        raise SystemExit(0)
raise SystemExit(1)
PY
'
    let l:cmd = substitute(l:cmd, '\n', ' ', 'g')
    let l:cmd = l:cmd . ' ' . shellescape(l:cc) . ' ' . shellescape(l:file)
    let l:resolved = system(l:cmd)
    if v:shell_error == 0 && !empty(trim(l:resolved))
      call s:run_shell(trim(l:resolved))
      return
    endif
  endif

  " Fallback: compile the project sources without linking.
  call vim_build#core#compile_all()
endfunction

function! vim_build#core#build_current() abort
  execute 'Dispatch! cmake --build ' . fnameescape(s:build_dir())
endfunction

function! vim_build#core#run_current() abort
  let l:exe = s:exe_path()
  if !filereadable(l:exe)
    echo "Executable not found: " . l:exe
    return
  endif
  execute 'Dispatch ' . fnameescape(l:exe)
endfunction

function! vim_build#core#build_and_run_current() abort
  let l:exe = s:exe_path()
  let l:buildcmd = 'cmake --build ' . s:build_dir()
  execute 'Dispatch! sh -c ' . shellescape(l:buildcmd . ' && ' . l:exe)
endfunction

function! s:clean_build(dir) abort
  let l:prompt = (a:dir =~# 'Debug') ? 'Clean Debug build directory?' : 'Clean Release build directory?'
  if confirm(l:prompt, "&Yes\n&No", 2) == 1
    execute 'Dispatch! cmake --build ' . fnameescape(a:dir) . ' --target clean'
  endif
endfunction

function! vim_build#core#clean_current() abort
  call s:clean_build(s:build_dir())
endfunction

function! vim_build#core#rebuild_current() abort
  call vim_build#core#clean_current()
  call vim_build#core#build_current()
endfunction

function! s:setup_cmake_mappings() abort
  let g:cpp_project_name = fnamemodify(s:get_project_dir(), ':t')
  if !exists('g:cpp_build_mode')
    let g:cpp_build_mode = 'Debug'
  endif
  echo "CMake mappings loaded for: " . getcwd()
endfunction

function! vim_build#core#setup_run_mappings_from_arg() abort
  if exists('g:cpp_run_mappings_initialized')
    return
  endif
  let g:cpp_run_mappings_initialized = 1

  let l:project_dir = s:get_project_dir()
  if !s:is_cmake_project(l:project_dir)
    return
  endif

  if confirm('CMakeLists.txt found. Load as a CMake project?', "&Yes\n&No", 2) != 1
    return
  endif

  call s:setup_cmake_mappings()
endfunction

function! vim_build#core#setup_cmake_project() abort
  let l:project_dir = getcwd()

  if !s:is_cmake_project(l:project_dir)
    echo "CMakeLists.txt not found in " . l:project_dir
    return
  endif

  call s:setup_cmake_mappings()
endfunction

function! vim_build#core#cmake_generate(...) abort
  let l:script = s:plugin_dir . '/scripts/cmake-cpp-init.sh'
  if !filereadable(l:script)
    let l:script = s:plugin_dir . '/scripts/cmake-init-cpp.sh'
  endif

  if !filereadable(l:script)
    echo "Generator script not found"
    return
  endif

  let l:target = (a:0 > 0 && a:1 !=# '') ? a:1 : getcwd()
  execute 'Dispatch! sh ' . shellescape(l:script) . ' ' . shellescape(l:target)
endfunction




"=============================================================================
" 		END AUTOLOAD: VIM-BUILD
"=============================================================================
