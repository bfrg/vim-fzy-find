" ==============================================================================
" Fuzzy-select files under a specified directory
" File:         plugin/fzyfind.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-fzy-find
" Last Change:  Aug 20, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if exists('g:loaded_fzyfind')
    finish
endif
let g:loaded_fzyfind = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command -nargs=? -complete=dir  Find call fzy#find#run(empty(<q-args>) ? getcwd() : <q-args>, 'edit', '')
command -nargs=? -complete=dir SFind call fzy#find#run(empty(<q-args>) ? getcwd() : <q-args>, 'split', <q-mods>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
