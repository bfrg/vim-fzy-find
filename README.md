# vim-fzy-find

Fuzzy-select files under a directory using the fuzzy-searcher [fzy][fzy] and
your favorite [find][find] command.

<dl>
  <p align="center">
  <a href="https://asciinema.org/a/274244">
    <img src="https://asciinema.org/a/274244.png" width="480">
  </a>
  </p>
</dl>

## Requirements

Vim, [vim-fzy][vim-fzy] (see [installation](#installation) instructions below).


## Usage

| Command                   | Description                                                           |
| ------------------------- | --------------------------------------------------------------------- |
| <kbd>:Find [dir]</kbd>    | Find files in `[dir]`, open selected file in current window.          |
| <kbd>:SFind [dir]</kbd>   | Same as <kbd>:Find</kbd>, but open the selected file in a new split.  |

`[dir]` is the directory to search in. If omitted, the search is performed in
the current working directory.

<kbd>:SFind</kbd> accept a **command modifier**. For example, to open the
selected file in a new vertical split, run <kbd>:vertical SFind</kbd>. <kbd>:tab
SFind</kbd> will open the selected file in a new tab. For a full list of
supported command modifiers, see <kbd>:help fzy-:SFind</kbd>.


## Configuration

Options can be passed to fzy through the dictionary `g:fzy`. Currently, the
following entries are supported:

| Entry       | Description                                                               | Default   |
| ----------- | ------------------------------------------------------------------------- | --------- |
| `lines`     | Specify how many lines of results to show. Sets the fzy `--lines` option. | `10`      |
| `prompt`    | Set the fzy input prompt.                                                 | `▶ `      |
| `showinfo`  | If true, fzy is invoked with the `--show-info` option.                    | `0`       |
| `findcmd`   | File-search command.                                                      | see below |

**Note:** The entries `lines`, `prompt` and `showinfo` are also used by the
plugin [vim-fzy-builtins][fzy-builtins] in order to provide a uniform fzy
interface.

Example:
```vim
let g:fzy = {
        \ 'lines': 15,
        \ 'prompt': '>>> ',
        \ 'showinfo': 1,
        \ 'findcmd': 'fd --type f --type l'
        \ }
```

If no `findcmd` entry is specified, the following is used:
```bash
find -name ".*" \! -name . \! -name .gitignore \! -name .vim \
  -prune -o \( -type f -o -type l \) \
  -printf "%P\n" 2>/dev/null
```

Broken down the expression means:
- Ignore all hidden files and directories, except for `.gitignore`, and `.vim`,
- print only files and symlinks.
- The `-printf` option is a GNU/find extension that will remove the `./` prefix
  from all file paths

The file-search command is always run in the specified search directory to avoid
listing long file paths.


## Tips and Tricks

Set your preferred file-search command only when it's available:
```vim
let g:fzy = {'lines': 15, 'prompt': '>> '}

if executable('fd')
    let g:fzy.findcmd = 'fd --type f --type l --exclude __pycache__'
elseif executable('rg')
    let g:fzy.findcmd = 'rg --files --no-messages'
elseif executable('ag')
    let g:fzy.findcmd = 'ag --silent --ignore __pycache__ -g ""'
endif
```

If you prefer shorter Ex commands, add the following to your `vimrc`:
```vim
" Fuzzy search and edit files recursively under a specified directory
command! -nargs=* -bar -complete=dir FE Find <args>
command! -nargs=* -bar -complete=dir FS <mods> SFind <args>
command! -nargs=* -bar -complete=dir FV vertical SFind <args>
command! -nargs=* -bar -complete=dir FT tab SFind <args>
```

If you prefer mappings over Ex commands, you might find the following useful:
```vim
" Edit files under current working directory
nnoremap <silent> <leader>fe :<c-u>Find<cr>
nnoremap <silent> <leader>fs :<c-u>SFind<cr>
nnoremap <silent> <leader>fv :<c-u>vertical SFind<cr>
nnoremap <silent> <leader>ft :<c-u>tab SFind<cr>
```


## Installation

#### Manual Installation

Run the following commands in your terminal:
```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-fzy
$ git clone https://github.com/bfrg/vim-fzy-find
$ vim -u NONE -c "helptags vim-fzy/doc" -c q
$ vim -u NONE -c "helptags vim-fzy-find/doc" -c q
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see <kbd>:help packages</kbd>.

#### Plugin Managers

Assuming [vim-plug][plug] is your favorite plugin manager, add the following to
your `vimrc`:
```vim
Plug 'bfrg/vim-fzy'
Plug 'bfrg/vim-fzy-find'
```


## License

Distributed under the same terms as Vim itself. See <kbd>:help license</kbd>.

[fzy]: https://github.com/jhawthorn/fzy
[find]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/find.html
[vim-fzy]: https://github.com/bfrg/vim-fzy
[fzy-builtins]: https://github.com/bfrg/vim-fzy-builtins
[plug]: https://github.com/junegunn/vim-plug
