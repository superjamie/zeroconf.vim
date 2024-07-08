" Name:        zeroconf.vim
" Description: Settings I like for Vim
" License:     Vim License, see :help license
" Maintainer:  Jamie Bainbridge <jamie.bainbridge@gmail.com>
" Last Change: 2024-07-08

if exists('g:loaded_zeroconf')
  finish
else
  let g:loaded_zeroconf = 'yes'
endif

""" general
set autoindent       " indent the same amount as the previous line on CR
set cindent          " C-style indenting
set noerrorbells     " BEEP (for DOS vim)
set foldlevelstart=99 " start with all folds open, ZM to close all levels, ZR to open all levels
set foldmethod=indent " fold based on indent level
set formatoptions-=c " stop comments wrapping at textwidth (:help fo-table)
set hidden           " allow moving to another buffer without saving
set hlsearch         " highlight search results
set incsearch        " incremental search as you type
set linebreak        " don't wrap text in the middle of a word
set listchars=tab:>\ ,eol:$,trail:-,extends:>,precedes:<,nbsp:+ "
set modeline         " https://vim.fandom.com/wiki/Modeline_magic
set mouse=           " disable mouse
set number           " show line numbers
set relativenumber   " enable hybrid line numbers
set scrolloff=1      " number of lines to keep visible when scrolling
set title            " show title in console
set ttimeoutlen=50   " timeout to consider Esc as Meta key
set smarttab         " tab on blank line inserts a shiftwidth, backspace deletes
set splitbelow       " start splits below the current window
set splitright       " start splits to the right of the current window
set wildmenu         " command autocompletion menu (try :color <Tab> to see)

set expandtab        " expand tabs to spaces
set tabstop=4        " consider 4 spaces to be a tab
set shiftwidth=4     " when < or > shifting, move to 4-space boundaries
" when halfway thru spacing and you hit tab, end at (shiftwidth) gaps
if has('softtabstop') | set softtabstop=-1 | endif

" put ~backups .swp .un~ in /tmp/%full%file%path instead of current directory
set backupdir=/tmp//
set directory=/tmp//
set undodir=/tmp//

""" clipboard (vim-gtk3)
" use system clipboard for all yank/delete/change/put operations
if has("unnamedplus")
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

""" gvim
if has("gui_running")
  "set guifont=PxPlus\ IBM\ VGA\ 8x16\ 12
  set guifont=DejaVu\ Sans\ Mono\ Bold\ 10
endif

""" filetypes and autogroups
augroup configs
    autocmd!
    autocmd BufNewFile,BufReadPost *.ino set filetype=c  " arduino
    autocmd BufWritePre *.py :%s/\s\+$//e  " strip trailing whitespace on save
    autocmd FileType c,cpp setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8 complete+=,i
    autocmd FileType c,cpp source ~/.vim/syntax/sdl2.vim
    autocmd FileType diff  setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8
    autocmd FileType make  setlocal noexpandtab
    autocmd FileType xml   setlocal   expandtab tabstop=2 shiftwidth=2 softtabstop=2
augroup END

" simpler version of https://github.com/farmergreg/vim-lastplace
augroup jump_to_this_files_last_cursor_position
    autocmd!
    " exclude invalid, event handler, and commit messages
    autocmd BufReadPost *
            \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
            \ |   exe "normal! g`\""
            \ | endif
augroup END

" use nested when sourcing vimrc - https://github.com/itchyny/lightline.vim/issues/102
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

""" key remaps
" buffers
noremap <silent> <leader>b :buffers<cr>
" close current buffer without closing split, switches to b# (previous buffer)
nnoremap <silent> <leader>d :b#<bar>bd#<CR>
" from vim-unimpaired
noremap [b :bprev<CR>
noremap ]b :bnext<CR>
noremap [B :bfirst<CR>
noremap ]B :blast<CR>
" buffer close
command Bc bp|bd#

" exit :terminal buffer insert mode with Esc
tnoremap <Esc> <C-\><C-n>

" quickfix list
noremap ]q :cnext<cr>
noremap [q :cprev<cr>

" E492 Not an editor command
command Q q
command W w

" disable command history (q:) and Ex mode (Q)
nnoremap q: <Nop>
nnoremap Q <Nop>

""" functions
" remove trailing whitespace, return to last position
function! Tw()
    %s/\s*$//
    ''
endfunction

" quickfix list
if exists('*getwininfo')
    function! ToggleQuickFix()
        if empty(filter(getwininfo(), 'v:val.quickfix'))
            copen
        else
            cclose
        endif
    endfunction
    nnoremap <silent> <leader>q :call ToggleQuickFix()<cr>
else
    nnoremap <leader>q :cclose<CR>
    nnoremap <leader>Q :copen<CR>
endif

" toggle right margin column visual aid
function! ColorColumn()
    if exists('+colorcolumn')
        if &colorcolumn != 81
            set colorcolumn=81,101,121
        else
            set colorcolumn=0
        endif
    else
        " fallback - highlight lines over 80 characters in red
        nnoremap <leader>8 :call matchadd('Search', '\%80v.\+', 100)<CR>:<Esc>
    endif
endfunction

""" leader maps
" left align line/selection to 1 space indent
map <silent> <leader><Space> :le 1<cr>
" look for lines over 80 characters
nnoremap <silent> <leader>8 :call ColorColumn()<CR>
" highlight cursor position
nnoremap <silent> <leader>c :set cursorline!<CR>:set cursorcolumn!<CR>
" remove search highlights by clearing last search pattern
"nnoremap <silent> <leader>h :nohl<CR>:match none<CR>:call clearmatches()<CR>
nnoremap <silent> <leader>h :let @/ = ""<cr>
" toggle list characters
nnoremap <leader>l :set list!<CR>:set list?<CR>
" toggle line numbers
nnoremap <silent> <leader>n :set relativenumber!<CR>:set number!<CR>
" toggle relative line numbers
nnoremap <silent> <leader><leader> :set relativenumber!<CR>
" toggle paste mode
nnoremap <leader>p :set paste!<CR>:set paste?<CR>
" spell check
nnoremap <leader>s :setlocal spell! spelllang=en_au<CR>:set spell?<CR>
" reload vim config, repply filetype to the current file so 'augroup Filetype' runs again
nnoremap <silent> <leader>v :source ~/.vimrc<CR>:exe ':set filetype='.&filetype<CR>
" remove trailing whitespace, return cursor to current position
nnoremap <silent> <leader>w :call Tw()<cr>:match none<CR>:call clearmatches()<CR>
" re-indent whole file (mm creates mark m, gg=G indents, `m goes to mark m)
map <Leader>= mmgg=G`m

"" tmux stuff
" cursor shape
" https://stackoverflow.com/questions/42377945/vim-adding-cursorshape-support-over-tmux-ssh
set t_SI=[6\ q
set t_SR=[4\ q
set t_EI=[2\ q
" undercurl
" https://github.com/vim/vim/issues/6174#issuecomment-636869793
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
" termguicolors
" https://stackoverflow.com/questions/62702766/termguicolors-in-vim-makes-everything-black-and-white
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

""" netrw
let g:netrw_sort_by="time"
let g:netrw_sort_direction="reverse"

