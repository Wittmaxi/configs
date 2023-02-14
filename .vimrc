" turn syntax highlights on             
syntax on
" turn on line numbers
set number
" make mouse usable
set mouse=a
" remove compatibility with vi
set nocompatible
" file type detection
filetype on
filetype plugin on
filetype indent on

" cursor line and column
set cursorline

" yank and put to/from clipboard
set clipboard=unnamedplus

" no line wrap
set nowrap

" scroll offset - always have 15 lines on top or below my cursor
set so=15

" Show which mode I am in
set showmode

" autocompleetion
set wildmenu
set wildmode=list:longest

" Omnicomplete
set omnifunc=syntaxcomplete#Complete
set omnifunc=javascriptcomplete#CompleteJS

set listchars=eol:¬,tab:>·,extends:>,precedes:<
set list

set expandtab
set shiftwidth=4
set smarttab
set tabstop=4

set virtualedit=all

set hlsearch
nnoremap <CR> :nohlsearch<CR><CR>

au VimEnter * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
au VimLeave * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Caps_Lock'

" folding
set foldmethod=syntax
set nofoldenable
set foldlevel=20

highlight Folded cterm=bold ctermbg=None ctermfg=blue

if has ("folding")
  nnoremap <Space> za
  vnoremap <Space> za


  set foldtext=FoldText()
  function! FoldText()
    let l:lpadding = &fdc
    redir => l:signs
      execute 'silent sign place buffer='.bufnr('%')
    redir End
    let l:lpadding += l:signs =~ 'id=' ? 2 : 0

    if exists("+relativenumber")
      if (&number)
        let l:lpadding += max([&numberwidth, strlen(line('$'))]) + 1
      elseif (&relativenumber)
        let l:lpadding += max([&numberwidth, strlen(v:foldstart - line('w0')), strlen(line('w$') - v:foldstart), strlen(v:foldstart)]) + 1
      endif
    else
      if (&number)
        let l:lpadding += max([&numberwidth, strlen(line('$'))]) + 1
      endif
    endif

    " expand tabs
    let l:start = substitute(getline(v:foldstart), '\t', repeat(' ', &tabstop), 'g')
    let l:end = substitute(substitute(getline(v:foldend), '\t', repeat(' ', &tabstop), 'g'), '^\s*', '', 'g')

    let l:info = ' (' . (v:foldend - v:foldstart) . ')'
    let l:infolen = strlen(substitute(l:info, '.', 'x', 'g'))
    let l:width = winwidth(0) - l:lpadding - l:infolen

    let l:separator = ' … '
    let l:separatorlen = strlen(substitute(l:separator, '.', 'x', 'g'))
    let l:start = strpart(l:start , 0, l:width - strlen(substitute(l:end, '.', 'x', 'g')) - l:separatorlen)
    let l:text = l:start . ' … ' . l:end

    return l:text . repeat(' ', l:width - strlen(substitute(l:text, ".", "x", "g"))) . l:info
  endfunction
endif

" absolute numbers in Imode, relative numbers in nmode
:set number

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END

" remap W to w because I sometimes press W isntead of w
command! W :w
command! Wq :wq


" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

" highlighting for MD files
autocmd BufRead,BufNew *.md set filetype=markdown



" vim Plug
call plug#begin('~/.vim/plugged')

Plug 'willchao612/vim-diagon'
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/goyo.vim', { 'for': 'markdown' }
Plug 'posva/vim-vue'
Plug 'mattn/emmet-vim'
Plug 'leafOfTree/vim-vue-plugin'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'zivyangll/git-blame.vim'
Plug 'vim-airline/vim-airline'
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'dense-analysis/ale'
Plug 'MarcWeber/vim-addon-local-vimrc'

call plug#end()


" NERDtree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
autocmd FileType nerdtree noremap <buffer> <space> <nop>
let NERDTreeMapActivateNode='<space>'

" make NERDTree buffer consistent - the same 
" nerdtree opens in ALL tabes
autocmd VimEnter * NERDTree
autocmd BufEnter * silent! NERDTreeMirror
autocmd VimEnter * wincmd p

" NERDTree git status
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

"vim vue plugin
let g:vim_vue_plugin_config = {
      \'syntax': {
      \   'template': ['html', 'pug'],
      \   'script': ['javascript', 'typescript', 'coffee'],
      \   'style': ['css', 'scss', 'sass', 'less', 'stylus'],
      \   'i18n': ['json', 'yaml'],
      \   'route': 'json',
      \},
      \'full_syntax': ['json'],
      \'initial_indent': ['i18n', 'i18n.json', 'yaml'],
      \'attribute': 1,
      \'keyword': 1,
      \'foldexpr': 1,
      \'debug': 0,
      \}


" vim git blame
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""
"                    APPEARANCE                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""
" Airline
""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_powerline_fonts = 1 " ASCII oder UNICODE
set laststatus=2


" neoplug and neosnippet
let g:deoplete#enable_at_startup = 1

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

" ale
let b:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'typescript': ['tslint'],
            \ 'java': [],
            \ 'sh': ['shfmt'],
            \ 'python': ['isort', 'yapf'],
            \ 'cpp': [],
            \ 'rust': ['rustfmt'],
            \ 'asm': []
            \ }

let b:ale_linters = {
            \ 'java': [],
            \ 'php': [],
            \ 'python': ["vulture"],
            \ 'rust': ['cargo'],
            \ 'cpp': [],
            \ 'asm': []
            \ }

let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')
let g:ale_python_vulture_options = "--min-confidence 100"


"""""""""""
" DEOPLETE
"""""""""""
let g:deoplete#enable_at_startup = 1
set completeopt-=preview  " remove preview window at the top
" autocmd CompleteDone * silent! pclose!  " close preview windows after completion
call deoplete#custom#option('sources', {
    \ 'cs': ['omnisharp'],
    \ })

"""""""""""""""""
" LanguageClient
"""""""""""""""""
let g:LanguageClient_serverCommands = {
            \ 'cpp': ['clangd'],
            \ 'c': ['clangd'],
            \ 'java': ['jdtls'],
            \ 'python': ['pyls'],
            \ 'rust': ['rustup', 'run', 'stable', 'rls'],
            \ 'dart': ['dart', "%", "--lsp"],
            \ 'fortran': ['fortls'],
            \ 'typescript': ['typescript-language-server', '--stdio'],
            \ 'javascript': ['/usr/lib/node_modules/javascript-typescript-langserver/lib/language-server-stdio.js'],
            \ 'javascript.jsx': ['/usr/lib/node_modules/javascript-typescript-langserver/lib/language-server-stdio.js'],
            \ 'asm': []
            \ }
" Requirements:
" Python: palantir
"   - pip install 'python-language-server[all]'
"   - https://github.com/palantir/python-language-server
" CPP: clangd
" Java: eclipse jdt ls
"   - https://github.com/eclipse/eclipse.jdt.ls
" Typescript: (maybe its outdated and languege-server-strio is the alternative)
"   - npm install -g typescript-language-server
" Javascript:
"   - npm -g install javascript-typescript-langserver
" Fortran:
"   - pip install fortran-language-server

let g:LanguageClient_diagnosticsEnable = 1
let g:LanguageClient_loggingLevel = 'DEBUG'
let g:LanguageClient_loggingFile = '/tmp/languageClient'
let g:LanguageClient_serverStderr = '/tmp/languageServer.stderr'
let g:LanguageClient_rootMarkers = ['*.csproj', '.root', 'project.*', 'compile_commands.json', '.git']
let g:LanguageClient_trace = 'verbose'
let g:LanguageClient_useVirtualText = "No"
set signcolumn=yes
