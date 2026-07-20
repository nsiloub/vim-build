" =========================
" VIM-BUILD
" =========================

let s:plugin_dir = fnamemodify(expand('<sfile>:p'), ':h')

function! ToggleQuickFix()
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    copen
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

function! s:GetBuildMode() abort
  return get(g:, 'cpp_build_mode', 'Debug')
endfunction

function! s:SetBuildMode(mode) abort
  if a:mode !=# 'Debug' && a:mode !=# 'Release'
    echo "Invalid build mode: " . a:mode
    return
  endif

  let g:cpp_build_mode = a:mode
  call s:SetupBuildMappings()
  echo "Build mode set to: " . a:mode
endfunction

command! BuildDebug   call <SID>SetBuildMode('Debug')
command! BuildRelease call <SID>SetBuildMode('Release')
command! BuildMode    echo "Current build mode: " . <SID>GetBuildMode()

function! s:CleanBuild(dir) abort
  let l:prompt = (a:dir =~# 'Debug') ? 'Clean Debug build directory?' : 'Clean Release build directory?'
  if confirm(l:prompt, "&Yes\n&No", 2) == 1
    execute 'Dispatch! cmake --build ' . fnameescape(a:dir) . ' --target clean'
  endif
endfunction

function! s:SetBinary(filename, mode, lhs) abort
  let l:bpath = getcwd() . "/bin/" . a:mode . "/" . a:filename
  execute 'nnoremap ' . a:lhs . ' :Dispatch ' . fnameescape(l:bpath) . '<CR>'
endfunction

function! s:SetBuildAndRun(mode, lhs) abort
  let l:exe = getcwd() . "/bin/" . a:mode . "/" . g:cpp_project_name
  let l:buildcmd = "cmake --build build/" . a:mode
  let l:runcmd = fnameescape(l:exe)
  execute 'nnoremap ' . a:lhs . ' :Dispatch! sh -c ' . shellescape(l:buildcmd . ' && ' . l:runcmd) . '<CR>'
endfunction

function! s:SetupBuildMappings() abort
  let l:mode = s:GetBuildMode()

  execute 'nnoremap <F2> :Dispatch! cmake --build build/' . l:mode . '<CR>'
  execute 'nnoremap <F4> :call <SID>CleanBuild(''build/' . l:mode . ''')<CR>'

  call s:SetBinary(g:cpp_project_name, l:mode, '<F3>')
  call s:SetBuildAndRun(l:mode, '<F5>')
endfunction

function! s:SetupCMakeMappings() abort
  let g:cpp_project_name = fnamemodify(s:GetProjectDir(), ':t')

  if !exists('g:cpp_build_mode')
    let g:cpp_build_mode = 'Debug'
  endif

  call s:SetupBuildMappings()
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

function! s:CMakeGenerate(...) abort
  let l:script = s:plugin_dir . '/scripts/cmake-init-cpp.sh'
  if !filereadable(l:script)
    echo "Generator script not found: " . l:script
    return
  endif

  let l:target = (a:0 > 0 && a:1 !=# '') ? a:1 : getcwd()
  execute 'Dispatch! sh ' . shellescape(l:script) . ' ' . shellescape(l:target)
endfunction

command! -nargs=? CMakeGenerate call <SID>CMakeGenerate(<f-args>)

if !exists('g:cpp_run_mappings_initialized')
  call SetupRunMappingsFromArg()
endif

" =========================
" END VIM-BUILD
" =========================

