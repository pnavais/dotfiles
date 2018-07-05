" ...........................................................................
"   ______               __           __ __          ___ ___ _______ _______
"  |   __ \.---.-.--.--.|  |--.---.-.|  |  |  ____  |   |   |_     _|   |   |
"  |    __/|  _  |  |  ||  _  |  _  ||  |  | |____| |   |   |_|   |_|       |
"  |___|   |___._|___  ||_____|___._||__|__|         \_____/|_______|__|_|__|
"                |_____|
" ...........................................................................

" Payball's VIM configuration
"""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => UI Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set expandtab                  " Converts tabs to spaces
set noswapfile                 " Disables swap files
set nobackup nowritebackup     " Disables backup files
set encoding=utf-8             " Read encoding
set fileencoding=utf-8         " Saving encoding
set termencoding=utf-8         " Terminal encoding
set termguicolors              " Use 256 colors
set number                     " Show line numbers
"set numberwidth=5              " Width of the line number column
set linebreak                  " Break lines at word (requires Wrap lines)
set showbreak=+++              " Wrap-broken line prefix
set textwidth=100              " Line wrap (number of cols)
set visualbell                 " Use visual bell (no beeping)
set hlsearch                   " Highlight all search results
set smartcase                  " Enable smart-case search
set lz                         " Don't redraw while executing macros
set ignorecase                 " Always case-insensitive
set incsearch                  " Searches for strings incrementally
set autoindent                 " Auto-indent new lines
set smartindent                " Enable smart-indent
set undolevels=1000            " Number of undo levels
set backspace=indent,eol,start " Backspace behaviour
set magic                      " Set magic on, for regex
set mat=2                      " How many tenths of a second to blink
"set ruler                      " Show row and column ruler information
set cursorline                 " Draws an horizontal line at cursor position
set showmatch                  " Show matching brackets
set hid                        " Change buffer without saving"

" Turn wild menu
set lsp=0
set wildmenu
set wildmode=list:longest

" Mapping delays
set timeoutlen=1000
" Key code delays
set ttimeoutlen=0

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Tab control
set noexpandtab   " tabs ftw
set smarttab      " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4     " the visible width of tabs
set softtabstop=4 " edit as if the tabs are 4 characters wide
set shiftwidth=4  " number of spaces to use for indent and unindent
set shiftround    " round indent to a multiple of 'shiftwidth'
set ttyfast       " faster redrawing

" code folding settings
set foldmethod=syntax " fold based on indent
set foldnestmax=10    " deepest fold is 10 levels
set nofoldenable      " don't fold by default
set foldlevel=1

" make backspace behave in a sane manner
set backspace=indent,eol,start

" Display extra whitespace
"set list listchars=tab:▸\ ,trail:·,nbsp:·,eol:¬

" Hide Separators in vertical splits
"set fillchars+=vert:\

" Make it obvious where 80 characters is
"set textwidth=80
"set colorcolumn=+1

" Switch syntax highlighting on
syntax enable

set rtp+=/.fzf

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Leader key
let mapleader=","

" Paste mode mapping
set pastetoggle=<F2>

" Moving up and down work as you would expect
nnoremap <silent> j gj
nnoremap <silent> k gk

" Open .vimrc in a new tab
nnoremap <leader>ev :vsplit $MYVIMRC<CR>

" Reload .vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

" Toggle cursorline
nnoremap <Leader>c :set cursorline!<CR>

" Switch between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

map <leader>wc :wincmd q<cr>

" Switch between buffers
nnoremap <silent> <leader>n :bp<CR>
nnoremap <silent> <leader>m :bn<CR>
"nnoremap <leader>b :ls<cr>:b<space>

" Hide higlighted matches after search
nnoremap <silent> <CR> :nohlsearch<CR>

" Remove trailing whitespaces in file
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

" Fix indentation
map <F7> mzgg=G`z

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')

" Vim-plugPlugins
Plug 'ctrlpvim/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular'
Plug 'vim-scripts/matchit.zip'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'ryanoasis/vim-devicons'
Plug 'pangloss/vim-javascript'
Plug 'jelera/vim-javascript-syntax'
Plug 'iCyMind/NeoSolarized'
Plug 'nanotech/jellybeans.vim'
Plug 'dracula/vim'
Plug 'flazz/vim-colorschemes'
Plug 'blueshirts/darcula'
Plug 'morhetz/gruvbox'
Plug '~/.fzf' | Plug 'junegunn/fzf.vim'

",Initialize plugin system
call plug#end()

" Plugins Configuration
"""""""""""""""""""""""

" NERDTree
nmap <C-n> :NERDTreeToggle<CR>
let NERDTreeHighlightCursorline=1
let NERDTreeIgnore = ['tmp', '.yardoc', 'pkg']
" show hidden files in NERDTree
let NERDTreeShowHidden=1

" Ctrl-P Fuzzy finder
"let g:ctrlp_map = '<leader>t'
"nnoremap <silent> <leader>t :CtrlP<CR>
nnoremap <silent> <leader>r :CtrlPBuffer<CR>
let g:ctrlp_dotfiles=1
let g:ctrlp_working_path_mode = 'ra'

" CtrlP ignore patterns
let g:ctrlp_custom_ignore = {
            \ 'dir': '\.git$\|node_modules$\|\.hg$\|\.svn$',
            \ 'file': '\.exe$\|\.so$'
            \ }

" search the nearest ancestor that contains .git, .hg, .svn
let g:ctrlp_working_path_mode = 2

" VIM Airline
set t_Co=256
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=0

" Javascript
let g:javascript_plugin_jsdoc = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Themes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Color scheme
set background=dark "dark|light

"colorscheme darcula
"colorscheme base16-ateliercave

" Gruvbox theme options
let g:gruvbox_italic = '1'
"let g:gruvbox_termcolors = 'medium' " Possible values soft, medium and hard
colorscheme gruvbox

" Solarized config
"set termguicolors
"colorscheme NeoSolarized