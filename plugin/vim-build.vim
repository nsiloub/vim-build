" =========================
" VIM-BUILD
" =========================

if exists('g:loaded_vim_build')
  finish
endif
let g:loaded_vim_build = 1

command! BuildDebug   call vim_build#core#set_build_mode('Debug')
command! BuildRelease call vim_build#core#set_build_mode('Release')
command! BuildMode    echo "Current build mode: " . vim_build#core#get_build_mode()
command! CMakeFolder  call vim_build#core#setup_cmake_project()
command! -nargs=? CMakeGenerate call vim_build#core#cmake_generate(<f-args>)

nnoremap <silent> <C-b> :call vim_build#core#toggle_quickfix()<CR>

if !exists('g:cpp_run_mappings_initialized')
  call vim_build#core#setup_run_mappings_from_arg()
endif

" =========================
" END VIM-BUILD
" =========================

