" =========================
" VIM-BUILD
" =========================

if exists('g:loaded_vim_build')
  finish
endif
let g:loaded_vim_build = 1

command! -nargs=0 VimBuildState        echo "VimBuildState: " . vim_build#core#get_vim_build_state()
command! -nargs=0 GenerateBoilerPlate  call vim_build#core#cmake_generate()
command! -nargs=0 CmakeOn              call vim_build#core#setup_cmake_project()

autocmd VimEnter * call vim_build#core#startup_project_detection()
autocmd DirChanged * call vim_build#core#directory_changed()

" If you want short commandlines abbreviations for the long vim commands
" You can set them like in the examples bellow
"cabbrev <expr> gbp   getcmdtype() ==# ':' && getcmdline() =~# '^gbp\%(\s\|$\)'   ? 'GenerateBoilerPlate' : 'gbp'
"cabbrev <expr> con   getcmdtype() ==# ':' && getcmdline() =~# '^con\%(\s\|$\)'   ? 'CmakeOn'             : 'con'
"cabbrev <expr> sdm   getcmdtype() ==# ':' && getcmdline() =~# '^sdm\%(\s\|$\)'   ? 'SetDebugMode'        : 'sdm'
"cabbrev <expr> srm   getcmdtype() ==# ':' && getcmdline() =~# '^srm\%(\s\|$\)'   ? 'SetReleaseMode'      : 'srm'
"cabbrev <expr> sbm   getcmdtype() ==# ':' && getcmdline() =~# '^sbm\%(\s\|$\)'   ? 'ShowBuildMode'       : 'sbm'
"cabbrev <expr> tqf   getcmdtype() ==# ':' && getcmdline() =~# '^tqf\%(\s\|$\)'   ? 'ToggleQuickFix'      : 'tqf'



" Key maps for vim-build
nnoremap <silent> <C-m> :ToggleQuickFix<CR>
nnoremap <silent> <C-b> :BuildAndRun<CR>
nnoremap <silent> <C-b>c :CleanBuilds<CR>
nnoremap <silent> <C-b>s :ShowOutputs<CR>


" =========================
" END VIM-BUILD
" =========================

