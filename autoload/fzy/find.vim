" ==============================================================================
" Fuzzy-select files under a specified directory
" File:         autoload/fzy/find.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-fzy-find
" Last Change:  Aug 20, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

const s:defaults = {
        \ 'prompt': '▶ ',
        \ 'lines': 10,
        \ 'showinfo': 0,
        \ 'findcmd': 'find '
        \   .. '-name ".*"'
        \   .. ' \! -name . \! -name .gitignore \! -name .vim'
        \   .. ' -prune -o \( -type f -o -type l \)'
        \   .. ' -printf "%P\n" 2>/dev/null'
        \ }

const s:get = {k -> get(g:, 'fzy', {})->get(k, s:defaults[k])}

function s:error(...)
    echohl ErrorMsg | echomsg call('printf', a:000) | echohl None
endfunction

function s:find_cb(dir, vimcmd, choice) abort
    let fpath = fnamemodify(a:dir, ':p:s?/$??') .. '/' .. a:choice
    let fpath = fnameescape(fnamemodify(fpath, ':.'))
    call histadd('cmd', a:vimcmd .. ' ' .. fpath)
    execute a:vimcmd fpath
endfunction

function fzy#find#run(dir, vimcmd, mods) abort
    if !isdirectory(expand(a:dir))
        return s:error('fzy-find: Directory "%s" does not exist', expand(a:dir))
    endif

    const path = expand(a:dir)->fnamemodify(':~')->simplify()
    const findcmd = printf('cd %s; %s', expand(path)->shellescape(), s:get('findcmd'))
    const editcmd = empty(a:mods) ? a:vimcmd : (a:mods .. ' ' .. a:vimcmd)

    return fzy#start(findcmd, funcref('s:find_cb', [path, editcmd]), {
            \ 'prompt': s:get('prompt'),
            \ 'lines': s:get('lines'),
            \ 'showinfo': s:get('showinfo'),
            \ 'statusline': printf(':%s [directory: %s]', editcmd, path)
            \ })
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
