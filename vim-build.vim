">>>>>>>>>>>>>>>>>>^^^^^^^^^^^^^^^^^^^^^^^^^^^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
">>>>>>>>>>>>>>>>>> 	    VIM-BUILD	      <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
">>>>>>>>>>>>>>>>>>___________________________<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


" Open vim-dispatch/quickfix window and scroll to bottom
function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        Copen
        cbottom
    else
        cclose
    endif
endfunction

nnoremap <C-b> :call ToggleQuickFix()<CR>

function! s:IsCMakeProject(dir) abort
  return filereadable(a:dir . '/CMakeLists.txt')
endfunction

function! s:GetProjectDir() abort
  if len(v:argv) == 1
    let l:arg = v:argv[0]
    if l:arg ==# '.'
      return getcwd()
    endif
    return fnamemodify(expand(l:arg), ':p')
  endif
  return getcwd()
endfunction

function! s:CleanBuild(dir) abort
  let l:prompt = (a:dir =~# 'Debug') ? 'Clean Debug build directory?' : 'Clean Release build directory?'
  if confirm(l:prompt, "&Yes\n&No", 2) == 1
    execute 'Dispatch! cmake --build ' . a:dir . ' --target clean'
  endif
endfunction

function! s:SetBinaryDebug(filename) abort
  let bpath = getcwd() . "/bin/Debug/" . a:filename
  execute "nnoremap <F3> :Dispatch " . bpath . " <CR> <bar> :Copen<CR>"
endfunction
function! s:SetBinaryRelease(filename) abort
  let bpath = getcwd() . "/bin/Release/" . a:filename
  execute "nnoremap <C-F3> :Dispatch " . bpath . " <CR> <bar> :Copen<CR>"
endfunction

function! s:SetBuildAndRunDebug() abort
  let exe = getcwd() . "/bin/Debug/" . g:cpp_project_name
  let cmd = "cmake --build build/Debug && " . exe
  execute "nnoremap <F5> :Dispatch! sh -c " . shellescape(cmd) . " <CR> <bar> :Copen<CR>"
endfunction

function! s:SetBuildAndRunRelease() abort
  let exe = getcwd() . "/bin/Release/" . g:cpp_project_name
  let cmd = "cmake --build build/Release && " . exe
  execute "nnoremap <C-F5> :Dispatch! sh -c " . shellescape(cmd) . " <CR> <bar> :Copen<CR>"
endfunction

function! s:SetupCMakeMappings() abort
  nnoremap <F2>   :Dispatch! make -C build/Debug    <CR>
  nnoremap <C-F2> :Dispatch! make -C build/Release  <CR>

  nnoremap <F4>   :call <SID>CleanBuild('build/Debug')<CR>
  nnoremap <C-F4> :call <SID>CleanBuild('build/Release')<CR>

  let g:cpp_project_name = fnamemodify(s:GetProjectDir(), ':t')

  call s:SetBinaryDebug(g:cpp_project_name)
  call s:SetBinaryRelease(g:cpp_project_name)
  call s:SetBuildAndRunDebug()
  call s:SetBuildAndRunRelease()
endfunction

function! SetupRunMappingsFromArg() abort
  if exists('g:cpp_run_mappings_initialized')
    return
  endif
  let g:cpp_run_mappings_initialized = 1

  let l:project_dir = s:GetProjectDir()

  if !s:IsCMakeProject(l:project_dir)
    return
  endif

  if confirm('CMakeLists.txt found. Load as a CMake project?', "&Yes\n&No", 2) != 1
    return
  endif

  call s:SetupCMakeMappings()
endfunction

function! SetupCMakeProject() abort
  let l:project_dir = getcwd()

  if !s:IsCMakeProject(l:project_dir)
    echo "CMakeLists.txt not found in " . l:project_dir
    return
  endif

  call s:SetupCMakeMappings()
  echo "CMake mappings loaded for: " . l:project_dir
endfunction

command! CMakeFolder call SetupCMakeProject()

if !exists('g:cpp_run_mappings_initialized')
  call SetupRunMappingsFromArg()
endif

">>>>>>>>>>>>>>>>>>^^^^^^^^^^^^^^^^^^^^^^^^^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
">>>>>>>>>>>>>>>>>> END BUILD/CMAKE SECTION <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
">>>>>>>>>>>>>>>>>>_________________________<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

