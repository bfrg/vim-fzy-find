" ==============================================================================
" Fuzzy-select files under a specified directory
" File:         autoload/fzy/find.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-fzy-find
" Last Change:  Aug 23, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

const s:findcmd =<< trim END
    find
    -name '.*'
    -a '!' -name .
    -a '!' -name .gitignore
    -a '!' -name .vim
    -a -prune
    -o '(' -type f -o -type l ')'
    -a -print 2> /dev/null
    | sed 's/^\.\///'
END

const s:defaults = {
        \ 'prompt': '▶ ',
        \ 'lines': 10,
        \ 'showinfo': 0,
        \ 'term_highlight': 'Terminal',
        \ 'findcmd': join(s:findcmd)
        \ }

const s:get = {k -> get(g:, 'fzy', {})->get(k, get(s:defaults, k))}

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
    const stl = printf(':%s [directory: %s]', editcmd, path)
    let opts = {
            \ 'prompt': s:get('prompt'),
            \ 'lines': s:get('lines'),
            \ 'term_highlight': s:get('term_highlight'),
            \ 'showinfo': s:get('showinfo'),
            \ 'statusline': stl
            \ }

    if get(g:, 'fzy', {})->has_key('popup')
        let popopts = {'popup': {'title': stl}}
        call extend(popopts.popup, s:get('popup'), 'keep')
        call extend(opts, popopts)
    endif

    return fzy#start(findcmd, funcref('s:find_cb', [path, editcmd]), opts)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
