set nocompatible
syntax enable
set encoding=utf-8

call pathogen#infect()
filetype plugin indent on
runtime macros/matchit.vim

set background=dark
color torte
set lazyredraw
set nonumber
set ruler       " show the cursor position all the time
set cursorline
set showcmd     " display incomplete commands
set shell=bash  " avoids munging PATH under zsh
let g:is_bash=1 " default shell syntax
set history=200 " remember more Ex commands
set completeopt=menu
set hidden

"" Whitespace
set nowrap                        " don't wrap lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode

" List chars
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the first column when wrap is
                                  " off and the line continues beyond the left of the screen
"" Searching
set hlsearch                      " highlight matches
set incsearch                     " incremental searching
set ignorecase                    " searches are case insensitive...
set smartcase                     " ... unless they contain at least one capital letter

if has("autocmd")
  " Python auto complete
  autocmd FileType python set omnifunc=pythoncomplete#Complete

  " JavaScript auto complete
  autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json set ft=javascript

  " make Python follow PEP8
  au FileType python set softtabstop=4 tabstop=4 shiftwidth=4

  " mark Jekyll YAML frontmatter as comment
  au BufNewFile,BufRead *.{md,markdown,html,xml} sy match Comment /\%^---\_.\{-}---$/
endif

" ctags support
set tags=./.ctags,.ctags;

" provide some context when editing
set scrolloff=3

" don't use Ex mode, use Q for formatting
map Q gq

" clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>

" basic list of shortcuts for the power user in all of us
let mapleader=","
map <leader>a :Ack!<space>
map <leader>n :NERDTreeToggle<cr>
map <leader>s :QTPY session<cr>
map <leader>tf :w<cr> :QTPY file verbose<cr>
map <leader>tc :w<cr> :QTPY class verbose<cr>
map <leader>tm :w<cr> :QTPY method verbose<cr>
map <leader>j :RopeGotoDefinition<cr>
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>
map <leader>d :FufFileWithCurrentBufferDir<CR>
map <leader>b :FufBuffer<CR>
map <leader>c :FufTag<CR>
map .. :w<cr>
nnoremap <leader><leader> <c-^>

" basic refactoring support
map <leader>rv :call RenameVariable()<cr>
map <leader>rn :RopeRename<cr>
map <leader>ev :RopeExtractVariable<cr>
map <leader>em :RopeExtractMethod<cr>
map <leader>im :RopeAutoImport<cr>
map <leader>fu :RopeFindOccurrences<cr>
map <leader>rf :call RenameFile()<cr>

" re-index the ctags file
map <leader>ri :silent! !ctags -Rf .ctags --extra=+f<cr><C-z><cr>

" find merge conflict markers
nmap <silent> <leader>cf <ESC>/\v^[<=>]{7}( .*\|$)<CR>

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

set backupdir=~/.vim/_backup    " where to put backup files.
set directory=~/.vim/_temp      " where to put swap files.

" decided not to use the default recovery
set nobackup
set noswapfile

if has("statusline") && !&cp
  set laststatus=2  " always show the status bar

  " Start the status line
  set statusline=%f\ %m\ %r

  " Add fugitive
  set statusline+=%{fugitive#statusline()}

  " Finish the statusline
  set statusline+=Line:%l/%L[%p%%]
  set statusline+=Col:%v
  set statusline+=Buf:#%n
  set statusline+=[%b][0x%B]
endif

" fuzzy finder height settings
let g:CommandTMaxHeight=12
let g:CommandTMinHeight=4

" fuzzy finder and nerd tree should ignore pyc files
let NERDTreeIgnore = ['\.pyc$']
set wildignore=*.swp,*.bak,*.pyc,*.class

" Rope AutoComplete
let ropevim_vim_completion = 1
let ropevim_extended_complete = 1
let g:ropevim_autoimport_modules = ["os.*","traceback","django.*","xml.etree"]

" Make pasting done without any indentation break
set pastetoggle=<F3>

" ,v Select just pasted text.
nnoremap <leader>v V`]

" ,ed Shortcut to edit .vimrc file on the fly on a vertical window
nnoremap <leader>ed <C-w><C-v><C-l>:e $MYVIMRC<cr>

" jj For Qicker Escaping between normal and editing mode
inoremap jj <ESC>

" Make Sure that Vim returns to the same line when we reopen a file"
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ execute 'normal! g`"zvzz' |
        \ endif
augroup END

" A few basic refactor methods below
function! GetSelectedText(...) 
  try
    let a_save = @a
    if a:0 >= 1 && a:1 == 1
      normal! gv"ad
    else
      normal! gv"ay
    endif
    return @a
  finally
    let @a = a_save
  endtry
endfunction

function! RenameVariable()
    let new_name = input("New variable name: ")
    let old_name = GetSelectedText()
    if new_name != '' && new_name != old_name
        exec ':%s /' . old_name . '/' . new_name . '/gc'
        redraw!
    endif
endfunction

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
