"=============================================================================
"==============================================================================
"
"		AUTOLOAD: VIM-BUILD
"
"==============================================================================
"===============================================================================



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
  call s:setup_build_mappings()
  echo "Build mode set to: " . a:mode
endfunction

function! s:clean_build(dir) abort
  let l:prompt = (a:dir =~# 'Debug') ? 'Clean Debug build directory?' : 'Clean Release build directory?'
  if confirm(l:prompt, "&Yes\n&No", 2) == 1
    execute 'Dispatch! cmake --build ' . fnameescape(a:dir) . ' --target clean'
  endif
endfunction

function! s:set_binary(filename, mode, lhs) abort
  let l:bpath = getcwd() . "/bin/" . a:mode . "/" . a:filename
  execute 'nnoremap <silent> ' . a:lhs . ' :Dispatch ' . fnameescape(l:bpath) . '<CR>'
endfunction

function! s:set_build_and_run(mode, lhs) abort
  let l:exe = getcwd() . "/bin/" . a:mode . "/" . g:cpp_project_name
  let l:buildcmd = "cmake --build build/" . a:mode
  let l:runcmd = fnameescape(l:exe)
  execute 'nnoremap <silent> ' . a:lhs . ' :Dispatch! sh -c ' . shellescape(l:buildcmd . ' && ' . l:runcmd) . '<CR>'
endfunction

function! s:setup_build_mappings() abort
  let l:mode = vim_build#core#get_build_mode()

  execute 'nnoremap <silent> <F2> :Dispatch! cmake --build build/' . l:mode . '<CR>'
  execute 'nnoremap <silent> <F4> :call s:clean_build(''build/' . l:mode . ''')<CR>'

  call s:set_binary(g:cpp_project_name, l:mode, '<F3>')
  call s:set_build_and_run(l:mode, '<F5>')
endfunction

function! s:setup_cmake_mappings() abort
  let g:cpp_project_name = fnamemodify(s:get_project_dir(), ':t')

  if !exists('g:cpp_build_mode')
    let g:cpp_build_mode = 'Debug'
  endif

  call s:setup_build_mappings()
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
  echo "CMake mappings loaded for: " . l:project_dir
endfunction

function! vim_build#core#cmake_generate(...) abort
  let l:script = s:plugin_dir . '/scripts/cmake-init-cpp.sh'
  if !filereadable(l:script)
    echo "Generator script not found: " . l:script
    return
  endif

  let l:target = (a:0 > 0 && a:1 !=# '') ? a:1 : getcwd()
  execute 'Dispatch! sh ' . shellescape(l:script) . ' ' . shellescape(l:target)
endfunction

