" ==============================================================================
" Fuzzy-select files under a specified directory
" File:         autoload/fzy/find.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-fzy-find
" Last Change:  Mar 3, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:defaults = {
        \ 'prompt': '▶ ',
        \ 'lines': 10,
        \ 'findcmd': 'find '
        \   .. '-name ".*"'
        \   .. ' \! -name . \! -name .gitignore \! -name .vim'
        \   .. ' -prune -o \( -type f -o -type l \)'
        \   .. ' -printf "%P\n" 2>/dev/null'
        \ }

let s:get = {k -> has_key(get(g:, 'fzy', {}), k) ? get(g:fzy, k) : get(s:defaults, k)}

function! s:error(msg) abort
    echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function! s:find_cb(dir, vimcmd, choice) abort
    let fpath = fnamemodify(a:dir, ':p:s?/$??') .. '/' .. a:choice
    let fpath = fnameescape(fnamemodify(fpath, ':.'))
    call histadd('cmd', a:vimcmd .. ' ' .. fpath)
    execute a:vimcmd fpath
endfunction

function! fzy#find#run(dir, vimcmd, mods) abort
    if !isdirectory(expand(a:dir))
        return s:error(printf('vim-fzy-find: Directory "%s" does not exist', expand(a:dir)))
    endif

    let path = simplify(fnamemodify(expand(a:dir), ':~'))
    let findcmd = printf('cd %s; %s', shellescape(expand(path)), s:get('findcmd'))
    let editcmd = empty(a:mods) ? a:vimcmd : (a:mods .. ' ' .. a:vimcmd)

    return fzy#start(findcmd, funcref('s:find_cb', [path, editcmd]), {
            \ 'prompt': s:get('prompt'),
            \ 'lines': s:get('lines'),
            \ 'showinfo': s:get('showinfo'),
            \ 'statusline': printf(':%s [directory: %s]', editcmd, path)
            \ })
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
