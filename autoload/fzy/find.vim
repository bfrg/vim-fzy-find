" ==============================================================================
" Fuzzy-select files under a specified directory
" File:         autoload/fzy/find.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-fzy-find
" Last Change:  Oct 14, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:error(msg) abort
    echohl ErrorMsg | echomsg a:msg | echohl None
    return 0
endfunction

let s:findcmd = 'find '
        \ .. '-name ".*"'
        \ .. ' \! -name . \! -name .gitignore \! -name .vim'
        \ .. ' -prune -o \( -type f -o -type l \)'
        \ .. ' -printf "%P\n" 2>/dev/null'

function! s:find_cb(dir, vimcmd, choice) abort
    let fpath = fnamemodify(a:dir, ':p:s?/$??') .. '/' .. a:choice
    let fpath = fnameescape(fnamemodify(fpath, ':.'))
    call histadd('cmd', a:vimcmd .. ' ' .. fpath)
    execute a:vimcmd fpath
endfunction

function! fzy#find#run(dir, vimcmd, ...) abort
    if !isdirectory(expand(a:dir))
        return s:error(printf('vim-fzy-find: Directory "%s" does not exist', expand(a:dir)))
    endif
    let path = simplify(fnamemodify(expand(a:dir), ':~'))

    if !exists('g:fzy') || !has_key(g:fzy, 'findcmd')
        let findcmd = printf('cd %s; %s', shellescape(expand(path)), s:findcmd)
    else
        let findcmd = printf('cd %s; %s', shellescape(expand(path)), get(g:fzy, 'findcmd'))
    endif

    let editcmd = a:0 ? empty(a:1) ? a:vimcmd : (a:1 . ' ' . a:vimcmd) : a:vimcmd
    return fzy#start(findcmd, function('s:find_cb', [path, editcmd]), {
            \ 'statusline': printf(':%s [directory: %s]', editcmd, path)
            \ })
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
