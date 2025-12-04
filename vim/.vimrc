" =============================================================================
" Leader Key
" =============================================================================
let mapleader = " "
let maplocalleader = " "

" =============================================================================
" General Options
" =============================================================================
set termguicolors
set hlsearch
set number
set relativenumber
set shiftwidth=2
set tabstop=2
set expandtab
set mouse=a
set breakindent
set undofile
set undodir=~/.vim/undodir
set ignorecase
set smartcase
set updatetime=250
set signcolumn=yes
"set clipboard=unnamedplus
set completeopt=menu,menuone,noselect
set conceallevel=2
set guicursor=
set scrolloff=10
set noswapfile
set nobackup
set noshowmode
set modifiable
set hidden
set incsearch
set autoindent
set smartindent
set wildmenu
set wildmode=longest:full,full
set laststatus=2
set showcmd
set backspace=indent,eol,start

" Create undo directory if it doesn't exist
if !isdirectory($HOME . "/.vim/undodir")
  call mkdir($HOME . "/.vim/undodir", "p")
endif

" =============================================================================
" Colorscheme
" =============================================================================
syntax enable
colorscheme gruber-darker

" =============================================================================
" Keymaps
" =============================================================================

" Move selected lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"" Yank to system clipboard
"nnoremap <leader>y "+y
"vnoremap <leader>y "+y
"nnoremap <leader>Y "+Y

" Switch to alternate file
nnoremap <leader>s :e #<CR>
vnoremap <leader>s :e #<CR>

" Clear search highlight
nnoremap <esc><esc> :nohlsearch<CR>

" File explorer (using netrw)
nnoremap <leader>pv :Explore<CR>

" =============================================================================
" Autocommands
" =============================================================================

" Highlight on yank
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank() 2>/dev/null || true
augroup END

" For Vim 8.0+, use this alternative for yank highlight
if has('timers') && !has('nvim')
  function! s:HighlightYank() abort
    let l:hi_group = 'IncSearch'
    let l:duration = 150
    
    if v:event.operator ==# 'y'
      let l:start = getpos("'[")
      let l:end = getpos("']")
      
      if l:start[1] == l:end[1]
        " Single line
        let l:pattern = '\%' . l:start[1] . 'l\%>' . (l:start[2] - 1) . 'c.\%<' . (l:end[2] + 1) . 'c'
      else
        " Multi line
        let l:pattern = '\%' . l:start[1] . 'l\%>' . (l:start[2] - 1) . 'c\_.*\%' . l:end[1] . 'l\%<' . (l:end[2] + 1) . 'c'
      endif
      
      let l:match_id = matchadd(l:hi_group, l:pattern)
      call timer_start(l:duration, {-> matchdelete(l:match_id)})
    endif
  endfunction
  
  augroup VimYankHighlight
    autocmd!
    autocmd TextYankPost * call s:HighlightYank()
  augroup END
endif

" Set filetype for .razor files
augroup RazorFiletype
  autocmd!
  autocmd BufRead,BufNewFile *.razor setfiletype cs
augroup END

" =============================================================================
" Netrw Configuration (built-in file explorer)
" =============================================================================
let g:netrw_banner = 0
let g:netrw_liststyle = 3
"let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" =============================================================================
" Status Line (basic version mimicking modern setups)
" =============================================================================
set statusline=
set statusline+=%#PmenuSel#
set statusline+=\ %{mode()}\ 
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ [%{&fileformat}]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
