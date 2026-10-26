"=============================================================================
" AUTOLOAD: VIM-BUILD
"=============================================================================

let s:run_buffer = -1



let s:plugin_dir = fnamemodify(expand('<sfile>:p'), ':h:h:h')

function! s:project_dir() abort
  return get(g:, 'cpp_project_dir', getcwd())
endfunction

function! s:is_cmake_project(dir) abort
  return filereadable(a:dir . '/CMakeLists.txt')
endfunction

function! s:is_enabled() abort
  return get(g:, 'vim_build_state', 'off') ==# 'on'
endfunction

function! s:set_vim_build_state(state) abort
  let g:vim_build_state = a:state
endfunction

function! vim_build#core#get_vim_build_state() abort
  return get(g:, 'vim_build_state', 'off')
endfunction

" Register commands
function! s:define_build_commands() abort
  command! -nargs=0 CmakeOff            call vim_build#core#disable_cmake_project()

  command! -nargs=0 SetDebugMode        call vim_build#core#set_build_mode('Debug')
  command! -nargs=0 SetReleaseMode      call vim_build#core#set_build_mode('Release')
  command! -nargs=0 ShowBuildMode       echo "Current build mode: " . vim_build#core#get_build_mode()

  command! -nargs=0 CompileAll          call vim_build#core#compile_all()
  command! -nargs=0 CompileCurrentFile  call vim_build#core#compile_current_file()
  command! -nargs=0 Build               call vim_build#core#build_current()
  command! -nargs=0 RunPreviousBuilds   call vim_build#core#run_previous_builds()
  command! -nargs=0 BuildAndRun         call vim_build#core#build_and_run_current()
  command! -nargs=0 CleanBuilds         call vim_build#core#clean_current()
  command! -nargs=0 Rebuild             call vim_build#core#rebuild_current()

  command! -nargs=0 ToggleQuickFix       call vim_build#core#toggle_quickfix()

  command! -nargs=0 ShowOutputs call vim_build#core#show_run_output()

endfunction

function! s:remove_build_commands() abort
  silent! delcommand CmakeOff

  silent! delcommand SetDebugMode
  silent! delcommand SetReleaseMode
  silent! delcommand ShowBuildMode

  silent! delcommand CompileAll
  silent! delcommand CompileCurrentFile
  silent! delcommand Build
  silent! delcommand RunPreviousBuilds
  silent! delcommand BuildAndRun
  silent! delcommand CleanBuilds
  silent! delcommand Rebuild

  silent! delcommand ToggleQuickFix
  silent! delcommand ShowOutputs

endfunction

function! s:enable_vim_build(dir) abort
  let g:cpp_project_dir = fnamemodify(a:dir, ':p:h')
  let g:cpp_project_name = fnamemodify(g:cpp_project_dir, ':t')
  if !exists('g:cpp_build_mode')
    let g:cpp_build_mode = 'Debug'
  endif
  let g:cpp_run_mappings_initialized = 1
  call s:set_vim_build_state('on')
  call s:define_build_commands()
endfunction

function! s:disable_vim_build() abort
  if exists('g:cpp_project_dir')
    unlet g:cpp_project_dir
  endif
  if exists('g:cpp_project_name')
    unlet g:cpp_project_name
  endif
  if exists('g:cpp_build_mode')
    unlet g:cpp_build_mode
  endif
  if exists('g:cpp_run_mappings_initialized')
    unlet g:cpp_run_mappings_initialized
  endif
  call s:set_vim_build_state('off')
  call s:remove_build_commands()
endfunction

function! s:activate_if_cmake(dir) abort
  if !s:is_cmake_project(a:dir)
    return 0
  endif

  if s:is_enabled()
    call s:enable_vim_build(a:dir)
    echo "CMake mappings loaded for: " . g:cpp_project_dir
    return 1
  endif

  if confirm('CMakeLists.txt found in this folder. Change to it and activate the build functionalities?', "&Yes\n&No", 2) != 1
    return 0
  endif

  execute 'cd' fnameescape(fnamemodify(a:dir, ':p:h'))
  call s:enable_vim_build(getcwd())
  echo "CMake mappings loaded for: " . g:cpp_project_dir
  return 1
endfunction

function! s:prompt_and_cd(dir) abort
  if confirm('CMakeLists.txt found in this folder. Change to it and activate the build functionalities?', "&Yes\n&No", 2) != 1
    return 0
  endif
  execute 'cd' fnameescape(fnamemodify(a:dir, ':p:h'))
  call s:enable_vim_build(getcwd())
  echo "CMake mappings loaded for: " . g:cpp_project_dir
  return 1
endfunction

function! vim_build#core#toggle_quickfix() abort
  if !s:is_enabled()
    echo "VimBuildState: off"
    return
  endif

  if empty(filter(getwininfo(), 'v:val.quickfix'))
    Copen
    cbottom
  else
    cclose
  endif
endfunction

function! s:get_project_dir() abort
  return s:project_dir()
endfunction

function! vim_build#core#get_build_mode() abort
  return get(g:, 'cpp_build_mode', 'Debug')
endfunction

function! vim_build#core#set_build_mode(mode) abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif

  if a:mode !=# 'Debug' && a:mode !=# 'Release'
    echo "Invalid build mode: " . a:mode
    return
  endif
  let g:cpp_build_mode = a:mode
  echo "Build mode set to: " . a:mode
endfunction

function! s:project_name() abort
  return get(g:, 'cpp_project_name', fnamemodify(s:project_dir(), ':t'))
endfunction

function! s:build_dir() abort
  return s:project_dir() . '/build/' . vim_build#core#get_build_mode()
endfunction

function! s:exe_path() abort
  return s:project_dir() . '/bin/' . vim_build#core#get_build_mode() . '/' . s:project_name()
endfunction

function! s:compile_commands_file() abort
  return s:project_dir() . '/build/' . vim_build#core#get_build_mode() . '/compile_commands.json'
endfunction

function! s:current_file() abort
  return expand('%:p')
endfunction

" If you don't want the quickfix window to pop up
" automatically after an operation (you want it only to run 
" in background), add a bang (!) after the Dispatch!. For example:
" execute 'Dispatch! cmake --build ' . fnameescape(s:build_dir()) . ' --target mySources'
" In That case you'll need to run :Copen manually

function! s:run_shell(cmd) abort
  execute 'Dispatch sh -c ' . shellescape(a:cmd)
endfunction

function! vim_build#core#compile_all() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif
  execute 'Dispatch cmake --build ' . fnameescape(s:build_dir()) . ' --target mySources'
endfunction

function! vim_build#core#compile_current_file() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif

  let l:file = s:current_file()
  if empty(l:file)
    echo "No current file"
    return
  endif

  let l:cc = s:compile_commands_file()
  if filereadable(l:cc)
    let l:cmd = 'python3 - <<''PY''
import json, os, sys
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

  call vim_build#core#compile_all()
endfunction

function! vim_build#core#build_current() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif
  execute 'Dispatch cmake --build ' . fnameescape(s:build_dir())
endfunction



" For interactivity in the editor. This requires a vim with
" a term_start() support. This could be checked with
":echo has('terminal'). 1=> has it; 0=>no
"
function! s:run_in_terminal(cmd) abort
  if !has('terminal')
    echoerr "This Vim was built without terminal support"
    return
  endif

  botright 12new
  call term_start(a:cmd, {'curwin': 1, 'term_finish': 'open'})
  let s:run_buffer = bufnr('%')
  setlocal bufhidden=hide
endfunction



function! vim_build#core#run_previous_builds() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif

  let l:exe = s:exe_path()
  if !filereadable(l:exe)
    echo "Executable not found: " . l:exe
    return
  endif

  call s:run_in_terminal([l:exe])
endfunction

function! vim_build#core#build_and_run_current() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif

  let l:cmd = 'cmake --build ' . shellescape(s:build_dir())
        \ . ' && exec ' . shellescape(s:exe_path())

  call s:run_in_terminal(['sh', '-c', l:cmd])
endfunction


function! vim_build#core#show_run_output() abort
  if s:run_buffer < 0 || !bufexists(s:run_buffer)
    echo "No saved run output"
    return
  endif

  execute 'botright sbuffer ' . s:run_buffer
  resize 12
endfunction




function! s:clean_build(dir) abort
  let l:prompt = (a:dir =~# 'Debug') ? 'Clean Debug build directory?' : 'Clean Release build directory?'
  if confirm(l:prompt, "&Yes\n&No", 2) == 1
    execute 'Dispatch cmake --build ' . fnameescape(a:dir) . ' --target clean'
  endif
endfunction

function! vim_build#core#clean_current() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif
  call s:clean_build(s:build_dir())
endfunction

function! vim_build#core#rebuild_current() abort
  if !s:is_enabled()
    echo "VimBuildState is off"
    return
  endif
  call vim_build#core#clean_current()
  call vim_build#core#build_and_run_current()
endfunction

function! s:setup_cmake_mappings() abort
  if !exists('g:cpp_project_dir')
    call s:enable_vim_build(getcwd())
    return
  endif
  call s:set_vim_build_state('on')
  call s:define_build_commands()
  echo "CMake mappings loaded for: " . g:cpp_project_dir
endfunction

function! vim_build#core#startup_project_detection() abort
  if argc() == 1 && isdirectory(argv(0))
    let l:dir = fnamemodify(argv(0), ':p')
    if s:is_cmake_project(l:dir)
      call s:prompt_and_cd(l:dir)
      return
    endif
  endif

  if s:is_enabled()
    call s:activate_if_cmake(getcwd())
  endif
endfunction

function! vim_build#core#directory_changed() abort
  if s:activate_if_cmake(getcwd())
    return
  endif
endfunction

function! vim_build#core#setup_run_mappings_from_arg() abort
  return vim_build#core#startup_project_detection()
endfunction

function! vim_build#core#setup_cmake_project() abort
  if get(g:, 'vim_build_state', 'off') ==# 'on'
    echo "VimBuildState is already on"
    return
  endif

  let l:project_dir = getcwd()

  if !s:is_cmake_project(l:project_dir)
    echo "CMakeLists.txt not found in " . l:project_dir
    return
  endif

  call s:enable_vim_build(l:project_dir)
  echo "CMake mappings loaded for: " . g:cpp_project_dir
endfunction

function! vim_build#core#disable_cmake_project() abort
  call s:disable_vim_build()
  echo "CMake features disabled"
endfunction

function! vim_build#core#cmake_generate(...) abort
  let l:script = s:plugin_dir . '/scripts/cmake-init-cpp.sh'

  if !filereadable(l:script)
    echo "Generator script not found: " . l:script
    return
  endif

  if !s:is_enabled()
    call s:enable_vim_build(getcwd())
  endif

  let l:target = input('Enter project folder/path: ', getcwd())
  if empty(l:target)
    return
  endif

  call term_start(['sh', l:script, l:target], {'curwin': v:true})
endfunction

"=============================================================================
" 		END AUTLOAD: VIM-BUILD
"=============================================================================

