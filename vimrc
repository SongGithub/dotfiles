call plug#begin(expand('~/.vim/bundle'))
" Use single quotes

Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go'
Plug 'shougo/neocomplete.vim'
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

" Auto Start NerdTREE
autocmd vimenter * NERDTree
" Go to document window
autocmd VimEnter * wincmd p

" Auto Start Neocomplete
let g:neocomplete#enable_at_startup = 1

" TagbarToggle
nmap <F6> :TagbarToggle<CR>

" Go Keybinding
" Tests
autocmd FileType go nmap <leader>t  <Plug>(go-test)
" Run
autocmd FileType go nmap <leader>r  <Plug>(go-run)

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" Auto Add Imports when saving go files
let g:go_fmt_command = "goimports"

" Fix Backspace mapping so it actually deletes
:set backspace=indent,eol,start

" Highlight
let g:go_highlight_functions = 1  
let g:go_highlight_methods = 1  
let g:go_highlight_structs = 1  
let g:go_highlight_operators = 1  
let g:go_highlight_build_constraints = 1  

" Neocomplete: Use smartcase.
let g:neocomplete#enable_smart_case = 1

" disable preview on autocomplete
set completeopt-=preview

" indentation
set expandtab
set autoindent
set smartindent
set tabstop=4
set softtabstop=2
set shiftwidth=2

