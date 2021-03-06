" To see a list of possible options, run `:options`.
" Use `za` to toggle the folds.
" Use `zR` to open all folds.
" Use `zM` to close all folds.

" important {{{1

set nocompatible " Use Vim's new abilities (ie. don't act like vi)

" plugin management {{{1

filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Code to run before plugins load

let g:angular_skip_alternate_mappings = 1
set rtp+=/usr/local/opt/fzf

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" list the plugins you wish to install here:

Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rails'
Plugin 'burnettk/vim-angular'
Plugin 'pangloss/vim-javascript'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-surround'
Plugin 'groenewege/vim-less'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'othree/html5.vim'
Plugin 'sjl/vitality.vim' " make vim play nicely with tmux
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-projectionist'
Plugin 'buztard/vim-rel-jump'
Plugin 'craigemery/vim-autotag'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets' " snippets for ultisnips
Plugin 'mileszs/ack.vim'    " interface to ag/Silver Searcher
Plugin 'MichaelRFairhurst/angular-dep.vim'
Plugin 'w0rp/ale' " async js lint engine
Plugin 'Valloric/YouCompleteMe'
Plugin 'ternjs/tern_for_vim' " provides JS support for YouCompleteMe
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve
 
" moving around, searching and patterns {{{1

set wrapscan " Continue search when bottom of document has been reached.
set hlsearch " highlight all matches for the last used search pattern
set ignorecase " ignore case when using a search pattern
set smartcase " override 'ignorecase' when pattern has upper case characters
set incsearch " highlight pattern matches as you search

" tags {{{1

" displaying text {{{1

set number " Display line numbers.
set relativenumber " Display relative rather than absolute numbers. Makes jumping down/up lines with n+j or n+k much easier.
                   " Note that as "set number" has been run, the actual line number will be displayed rather than 0.
set scrolloff=3 " Number of screen lines to show around the cursor.
set wrap " long lines wrap

" syntax, highlighting and spelling {{{1

syntax enable
filetype plugin indent on " Vim will try to recognize the type of the file and set the 'filetype' option.
set background=light " 'dark' or 'light'; the background color brightness
colorscheme solarized
set cursorline " Highlight the screen line of the cursor
set colorcolumn=80 " Display a pale line 80 chars in (to help maintain reasonable line width)
autocmd FileType ruby set sw=2 sts=2 et

" multiple windows {{{1

set laststatus=2 " 0, 1 or 2; when to use a status line for the last window (Always display status bar)
set splitbelow " new hoz splits go below
set splitright " new vert splits go right

" multiple tab pages {{{1

" terminal {{{1

set ttyfast " Terminal connection is fast (smooth scrolling)
if !has("Win32")
  set term=screen-256color
endif

" using the mouse {{{1

set mouse=a  " Mouse in all modes
set mousehide  " Hide mouse after chars typed

" GUI {{{1

" printing {{{1

" messages and info {{{1

set cf " Start a dialog when a command fails
set showmode " Display the current mode in the status line
set showcmd " Show (partial / incomplete) command keys in the status line
set ruler " Show cursor position below each window

" selecting text {{{1

" editing text {{{1

set nosm  " when inserting a bracket, do NOT briefly jump to it's match
set backspace=indent,eol,start " specifies what <BS>, CTRL-W, etc. can do in Insert mode
set formatoptions=qrn1 " list of flags that tell how automatic formatting works

" tabs and indenting {{{1

set tabstop=4 " Number of spaces that a <Tab> in the file counts for.
set shiftwidth=4 " Number of spaces to use for each step of (auto)indent. Used for 'cindent', >>, <<, etc.
set expandtab " In Insert mode: Use the appropriate number of spaces to insert a <Tab>.

" folding {{{1

" diff mode {{{1

set diffopt=vertical " Option settings for diff mode.

" mapping {{{1

set timeoutlen=450  " Time to wait after ESC (default causes an annoying delay).
                    " Also it's the time between key presses for mappings.

" reading and writing files {{{1

" the swap file {{{1

" Determine where to put swap files
if has("win32") || has("win64")
   set directory=$TMP
else
   set directory=/tmp
end 

" command line editing {{{1

set history=256  " How many command lines are remembered.
set wildmenu " Command-line completion shows a list of matches.
set wildmode=list:longest,full " Specifies how command line completion works

" executing external commands {{{1

" running make and jumping to errors {{{1

" system specific {{{1

" language specific {{{1

" multi-byte characters {{{1

" various {{{1

set virtualedit+=block " Allow moving after the end of the line in visual block mode
set gdefault " Apply global substitutions on all lines by default

" Other - ie. couldn't find a home above... {{{1

set nobackup " Do not generate the ~files

" Plugin specific options {{{1

" fugitive options
" ----------------
autocmd QuickFixCmdPost *grep* cwindow " have Glog open the quickfix list

" cltrp
" -----

set wildignore+=*/node_modules/*
set wildignore+=*/bower_components/*

" ultisnips (snippets)
" --------------------

let g:UltiSnipsExpandTrigger="<c-j>" " Expand the snippet when using YouCompleteMe
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" ack
" ---

" Enable ack to use ag (Silver Searcher)
if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif

" ale
" ---

let g:ale_fixers = {
  \ 'javascript': ['eslint']
  \ }

" Custom Mappings {{{1

let mapleader = "," " Map a leader key
let maplocalleader = "\\" " Map a local leader key (\)

" map j to gj and k to gk, so line navigation ignores line wrap
nmap j gj
nmap k gk

" Map <F5> to insert date/time
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>

" leader + u to uppercase current word whilst in insert or normal mode 
inoremap <leader>u <esc>viwUea
nnoremap <leader>u viwUe

nnoremap <leader>o :only<cr>

" zz to save in normal mode
nnoremap zz :w<cr>

" Leader nv to open new vertical window
nnoremap <leader>nv :vnew<CR>

" Leader ; to append a semicolon to the current line
nnoremap <leader>; mqA;<esc>`q

" Error List mappings
" -------------------

" Leader ee to jump to next error (quick and simply to hit, harder to remember)
nnoremap <leader>ee :lnext<cr>

" Leader ne to jump to next error (hard to hit, easier to remember)
nnoremap <leader>ne :lnext<cr>

" Leader EE to jump to previous error (quick and simply to hit, harder to remember)
nnoremap <leader>EE :lprev<cr>

" Leader pe to jump to previous error (hard to hit, easier to remember)
nnoremap <leader>pe :lprev<cr>

" Leader se to display error list
nnoremap <leader>se :Errors<cr>

" Quick List results
" ------------------

" Leader ns to go to next item in Quick List (eg. grep result)
nnoremap <leader>ns :cn<cr>

" Leader ps to go to previous item in Quick List (eg. grep result)
nnoremap <leader>ps :cN<cr>

" Tab navigation mappings
" -----------------------

" Leader . to go to next tab.
nnoremap <leader>. :tabnext<cr>

" Leader m to go to next tab.
nnoremap <leader>m :tabprev<cr>


" Editing vim files mappings
" --------------------------

" leader + ev to open vimrc (in vertical panel)
nnoremap <leader>ev :vsplit $MYVIMRC<cr>

" leader + sv to source vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>

" leader + s to save and source current file
nnoremap <leader>s :w<cr>:source %<cr>

" Markdown related shortcuts:
" --------------------------

" Insert a line (h1 in Markdown) that equals length of current line
nnoremap <leader>1 yypVr=

" Insert a line (h2 in Markdown) that equals length of current line
nnoremap <leader>2 yypVr-

" Git related shortcuts:
" --------------------------

" leader gp to Git Push
nnoremap <leader>gp :Git push<CR>

" leader gs to Gstatus
nnoremap <leader>gs :Gstatus<CR>

" Leader gd to Gdiff
nnoremap <leader>gd :Gdiff<CR>

" Gulp related shortcuts:
" -----------------------

" leader l to compile less
nnoremap <leader>l :Dispatch! gulp compile-less<CR>

" fzf mappings
" ------------

" The following are based on:
" https://jesseleite.com/posts/2/its-dangerous-to-vim-alone-take-fzf

nmap <c-p> :GFiles<CR> " Search files held in git
nmap <Leader>F :Files<CR> " Search all files
nmap <Leader>b :Buffers<CR> " Search open buffers
nmap <Leader>h :History<CR> " Search buffer history
nmap <Leader>t :BTags<CR> " Search tags in current buffer
nmap <Leader>T :Tags<CR> " Search tags across project (requires a tag file)
nmap <Leader>l :BLines<CR> " Search lines in current buffer
nmap <Leader>L :Lines<CR> " Search lines in loaded buffers
nmap <Leader>' :Marks<CR> " Search marked lines
nmap <Leader>H :Helptags!<CR> " Search Help
nmap <Leader>: :History:<CR> " Search command history
nmap <Leader>/ :History/<CR> " Search /search history
nmap <Leader>M :Maps<CR> " Search key mappings
nmap <Leader>a :Ag<Space>

" More inspiration here:
" https://github.com/junegunn/fzf.vim#commands

" Abbreviations {{{1

iabbrev teh the

" AutoCmds {{{1

" Enable spellcheck for markdown and text files
augroup spellcheck
    " Clear previous versions of this group:
    autocmd!
    autocmd FileType markdown,text setlocal spell
augroup END

" Vimscript file settings 
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Compile less when a less file is saved.
augroup filetype_less
    autocmd!
    autocmd BufWritePost *.less Dispatch! gulp compile-less
augroup END

" Compile javascript when a javascript file is saved.
augroup filetype_javascript
    autocmd!
    autocmd BufWritePost *.js Dispatch! gulp compile-javascript
augroup END

" Provide support for using Vim in ConEmu (with PowerShell)  {{{1

if !empty($CONEMUBUILD)
    set term=xterm
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    set bs=indent,eol,start
    let g:solarized_termcolors=256
    set background=light " 'dark' or 'light'; the background color brightness
    colorscheme solarized
endif

" Provide a way to overide these settings locally by creating a '.local' file. {{{1
if has("Win32")
  if filereadable(expand("$VIM/_vimrc.local"))
    source $VIM/_vimrc.local
  endif
elseif has("mac")
  if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
  endif
endif
