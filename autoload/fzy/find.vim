" ==============================================================================
" Fuzzy-select files under a specified directory
" File:         autoload/fzy/find.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-fzy-find
" Last Change:  Oct 12, 2020
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

function s:error(...)
    echohl ErrorMsg | echomsg call('printf', a:000) | echohl None
endfunction

function s:find_cb(dir, vimcmd, choice) abort
    let fpath = fnamemodify(a:dir, ':p:s?/$??') .. '/' .. a:choice
    let fpath = fnamemodify(fpath, ':.')->fnameescape()
    call histadd('cmd', a:vimcmd .. ' ' .. fpath)
    execute a:vimcmd fpath
endfunction

function fzy#find#run(dir, vimcmd, mods) abort
    if !isdirectory(expand(a:dir))
        return s:error('fzy-find: Directory "%s" does not exist', expand(a:dir))
    endif

    const path = expand(a:dir)->fnamemodify(':~')->simplify()
    const findcmd = printf('cd %s; %s',
            \ expand(path)->shellescape(),
            \ get(g:, 'fzy', {})->get('findcmd', join(s:findcmd))
            \ )
    const editcmd = empty(a:mods) ? a:vimcmd : (a:mods .. ' ' .. a:vimcmd)
    const stl = printf(':%s [directory: %s]', editcmd, path)
    let opts = get(g:, 'fzy', {})->copy()->extend({'statusline': stl, 'prompt': '▶ '})
    call get(opts, 'popup', {})->extend({'title': stl})

    return fzy#start(findcmd, funcref('s:find_cb', [path, editcmd]), opts)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
