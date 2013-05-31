set nocompatible
syntax enable
set encoding=utf-8
set t_Co=256

call pathogen#infect()
filetype plugin indent on
runtime macros/matchit.vim

set background=dark
color evening
colorscheme railscasts
set lazyredraw
set nonumber
set ruler                         " show the cursor position all the time
set cursorline
set showcmd                       " display incomplete commands
set shell=bash                    " avoids munging PATH under zsh
let g:is_bash=1                   " default shell syntax
set history=200                   " remember more Ex commands
set completeopt=menu
set hidden

set nowrap                        " don't wrap lines
set tabstop=4                     " a tab is four spaces
set shiftwidth=4                  " an autoindent (with <<) is four spaces
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode

set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when line continues to the right
set listchars+=precedes:<         " The character to show in the first column when line continues to the left

set hlsearch                      " highlight matches
set incsearch                     " incremental searching
set ignorecase                    " searches are case insensitive...
set smartcase                     " ... unless they contain at least one capital letter

" Show relative line numbers in cmd mode
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

" Global settings for powerline
let g:Powerline_symbols = 'compatible'
set fillchars+=stl:\ ,stlnc:\

" Global setting for easy motion
let g:EasyMotion_leader_key = '<Leader>l'

" Global settings for Ctrl-P (fuzzy finder)
let g:ctrlp_map = '<Leader>ff'
let g:ctrlp_custom_ignore = 'node_modules$\|xmlrunner$\|.DS_Store|.git|.bak|.swp|.pyc'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_switch_buffer = 0
let g:ctrlp_max_height = 18

if has("autocmd")
    " Python auto complete
    autocmd FileType python set omnifunc=pythoncomplete#Complete

    " JavaScript auto complete
    autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

    " make JavaScript code formatting rules match python
    au FileType javascript set softtabstop=4 tabstop=4 shiftwidth=4

    " make CoffeeScript code formatting rules match python
    au FileType coffee set softtabstop=2 tabstop=2 shiftwidth=2

    " make Python follow PEP8 (mostly)
    au FileType python set softtabstop=4 tabstop=4 shiftwidth=4

    " Treat JSON files like JavaScript
    au BufNewFile,BufRead *.json set ft=javascript
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

" shortcut to save the current document
map .. :w<cr>

" go to definition
map <leader>j :call JumpToDefinition()<cr>

" like grep on steroids
map <leader>a :Ack!<space>

" basic file system navigation view
map <leader>d :NERDTreeToggle<cr>
nmap <leader>nt :NERDTreeFind<CR>

" python unit testing shortcuts to show the session + test by file/class/method
map <leader>ts :QTPY session<cr>
map <leader>tf :w<cr> :QTPY file verbose<cr>
map <leader>tc :w<cr> :QTPY class verbose<cr>
map <leader>tm :w<cr> :QTPY method verbose<cr>

" search the ctags index file for anything by class or method name
map <leader>fs :CtrlPTag<CR>

" search all files in the current files directory
map <leader>fd :CtrlPCurFile<CR>

" search all the files you have open in your vim buffer
map <leader>fb :CtrlPBuffer<CR>

" opens a new window from the buffer directory
map <leader>wn :new %:p:h<CR>

" go to the last file you had open
nmap <leader><leader> <c-^>

" basic refactoring support
map <leader>rv :call RenameVariable()<cr>
map <leader>rn :RopeRename<cr>
map <leader>ev :RopeExtractVariable<cr>
map <leader>em :RopeExtractMethod<cr>
map <leader>im :RopeAutoImport<cr>
map <leader>fu :RopeFindOccurrences<cr>
map <leader>rf :call RenameFile()<cr>
map <leader>cf :call CopyFile()<cr>

" re-index the ctags file
nnoremap <leader>ri :call RenewTagsFile()<cr>

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

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

" fuzzy finder and nerd tree should ignore pyc files
let NERDTreeIgnore = ['\.pyc$']
set wildignore=*.swp,*.bak,*.pyc,*.class,node_modules/**

" Rope AutoComplete
let ropevim_vim_completion = 1
let ropevim_extended_complete = 1
let g:ropevim_autoimport_modules = ["os.*","traceback","django.*","xml.etree"]

" Make pasting done without any indentation break
set pastetoggle=<F3>

" ,ed Shortcut to edit .vimrc file on the fly on a vertical window
nnoremap <leader>ed <C-w><C-v><C-l>:e $MYVIMRC<cr>

" jj For Qicker Escaping between normal and editing mode
inoremap jj <ESC>

au FocusLost * :silent! wall
set autowriteall

"Strip trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

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

function! CopyFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
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

function! RenewTagsFile()
    exe 'silent !rm -rf .ctags'
    exe 'silent !coffeetags --include-vars -Rf .ctags'
    exe 'silent !ctags -a -Rf .ctags --languages=python --python-kinds=-iv --exclude=build --exclude=dist ' . system('python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"')''
    exe 'silent !ctags -a -Rf .ctags --extra=+f --exclude=.git --languages=python --python-kinds=-iv --exclude=build --exclude=dist 2>/dev/null'
    exe 'redraw!'
endfunction

function! JumpToDefinition()
    let filetype=&ft
    if filetype == 'python'
        exe ':RopeGotoDefinition'
    else
        :exe "norm \<C-]>"
    endif
endfunction
