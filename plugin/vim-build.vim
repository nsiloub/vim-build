" =========================
" VIM-BUILD
" =========================

if exists('g:loaded_vim_build')
  finish
endif
let g:loaded_vim_build = 1

command! -nargs=0 GenerateBoilerPlate call vim_build#core#cmake_generate(<f-args>)
command! -nargs=0 CmakeOn             call vim_build#core#setup_cmake_project()

command! -nargs=0 SetDebugMode        call vim_build#core#set_build_mode('Debug')
command! -nargs=0 SetReleaseMode      call vim_build#core#set_build_mode('Release')
command! -nargs=0 ShowBuildMode       echo "Current build mode: " . vim_build#core#get_build_mode()

command! -nargs=0 VCompileAll         call vim_build#core#compile_all()
command! -nargs=0 VCompileCurrent     call vim_build#core#compile_current()
command! -nargs=0 VBuild              call vim_build#core#build_current()
command! -nargs=0 VRunCurrent         call vim_build#core#run_current()
command! -nargs=0 VBuildAndRun        call vim_build#core#build_and_run_current()
command! -nargs=0 VClean              call vim_build#core#clean_current()
command! -nargs=0 VRebuild            call vim_build#core#rebuild_current()

command! -nargs=0 ToggleQuickFix       call vim_build#core#toggle_quickfix()

cabbrev <expr> vca   getcmdtype() ==# ':' && getcmdline() =~# '^vca\%(\s\|$\)'   ? 'VCompileAll'     : 'vca'
cabbrev <expr> vcc   getcmdtype() ==# ':' && getcmdline() =~# '^vcc\%(\s\|$\)'   ? 'VCompileCurrent' : 'vcc'
cabbrev <expr> vb    getcmdtype() ==# ':' && getcmdline() =~# '^vb\%(\s\|$\)'    ? 'VBuild'          : 'vb'
cabbrev <expr> vrc   getcmdtype() ==# ':' && getcmdline() =~# '^vrc\%(\s\|$\)'   ? 'VRunCurrent'     : 'vrc'
cabbrev <expr> vbar  getcmdtype() ==# ':' && getcmdline() =~# '^vbar\%(\s\|$\)'  ? 'VBuildAndRun'    : 'vbar'
cabbrev <expr> vc    getcmdtype() ==# ':' && getcmdline() =~# '^vc\%(\s\|$\)'    ? 'VClean'          : 'vc'
cabbrev <expr> vrb   getcmdtype() ==# ':' && getcmdline() =~# '^vrb\%(\s\|$\)'   ? 'VRebuild'        : 'vrb'

cabbrev <expr> gpb   getcmdtype() ==# ':' && getcmdline() =~# '^gpb\%(\s\|$\)'   ? 'GenerateBoilerPlate' : 'gpb'
cabbrev <expr> con   getcmdtype() ==# ':' && getcmdline() =~# '^con\%(\s\|$\)'   ? 'CmakeOn'             : 'con'
cabbrev <expr> sdm   getcmdtype() ==# ':' && getcmdline() =~# '^sdm\%(\s\|$\)'   ? 'SetDebugMode'        : 'sdm'
cabbrev <expr> srm   getcmdtype() ==# ':' && getcmdline() =~# '^srm\%(\s\|$\)'   ? 'SetReleaseMode'      : 'srm'
cabbrev <expr> sbm   getcmdtype() ==# ':' && getcmdline() =~# '^sbm\%(\s\|$\)'   ? 'ShowBuildMode'       : 'sbm'
cabbrev <expr> tqf   getcmdtype() ==# ':' && getcmdline() =~# '^tqf\%(\s\|$\)'   ? 'ToggleQuickFix'      : 'tqf'

nnoremap <silent> <C-b> :call vim_build#core#toggle_quickfix()<CR>

if !exists('g:cpp_run_mappings_initialized')
  call vim_build#core#setup_run_mappings_from_arg()
endif

" =========================
" END VIM-BUILD
" =========================

