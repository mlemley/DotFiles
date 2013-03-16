set t_Co=256
colorscheme dante
set autoindent
set expandtab
set hardtabs=4
set tabstop=4
set shiftwidth=4
set winwidth=120
set winheight=70
set ruler
set number
set fileformat=unix
set incsearch
set wrap
set backspace=2
set ignorecase
set hls
syntax on
filetype plugin on

call pathogen#infect() 

ino <tab> <c-r>=TriggerSnippet()<cr>
snor <tab> <esc>i<right><c-r>=TriggerSnippet()<cr>

map <C-j> <C-W><DOWN>
map <C-k> <C-W><UP>
map <C-h> <C-W><LEFT>
map <C-l> <C-W><RIGHT>

map <F2> :set hlsearch!<CR>
map <F3> :%s///g<Cr>
map <F4> :TlistToggle<CR>

function License_notice(file_name)
  let path_file_name = $HOME . "/.vim/" . a:file_name
    execute 'r ' . path_file_name
endfunction

function ClearWhiteSpace()
    let save_cursor = getpos(".")
    %s/\s\+$//e
    %s///e
    %s///e
    call setpos(".", save_cursor)
endfunction

highlight ExtraWhitespace ctermbg=red guibg=red
au ColorScheme * highlight ExtraWhitespace guibg=red
au BufEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\s\+$/

" deleate extra white spaces on save
au BufWritePre *.as call ClearWhiteSpace()
au BufWritePre *.mxml call ClearWhiteSpace()
au BufWritePre *.xml call ClearWhiteSpace()
au BufWritePre *.html call ClearWhiteSpace()
au BufWritePre *.py call ClearWhiteSpace()
au BufWritePre *.pd call ClearWhiteSpace()
au BufWritePre *.css call ClearWhiteSpace()
au BufWritePre *.js call ClearWhiteSpace()
au BufWritePre *.java call ClearWhiteSpace()

au BufRead,BufNewFile *.as set filetype=actionscript
au BufRead,BufNewFile *.mxml set filetype=mxml
au BufNewFile,BufRead *.pd setlocal filetype=html
au BufNewFile,BufRead *.pd map <F6> :sp %<.py<CR>
au BufRead,BufNewFile *.java set filetype=java
au BufRead,BufNewFile *.feature call SetupTwoSpacedTabs()
au BufRead,BufNewFile *.rb call SetupTwoSpacedTabs()
au BufRead,BufNewFile *.js call SetupTwoSpacedTabs()

"" auto complete block closure and set cursor inside indented in
inoremap {<CR> {<CR>}<C-O>O<TAB>

function! SetupTwoSpacedTabs()
    set hardtabs=2
    set tabstop=2
    set shiftwidth=2
endfunction

function! GreenBar(message)
    hi GreenBar ctermfg=white ctermbg=green guibg=green
    echohl GreenBar
    echon repeat(" ",&columns)
    echohl
    echo a:message
endfunction

function! RedBar(message)
    hi RedBar ctermfg=white ctermbg=red guibg=red
    echohl RedBar
    echon repeat(" ",&columns)
    echohl
    echo a:message
endfunction

function! ExtractVariable()
    let name = input("Variable name: ")
    if name == ''
        return
    endif
    " Enter visual mode (not sure why this is needed since we're already in
    " visual mode anyway)
    normal! gv

    " Replace selected text with the variable name
    exec "normal c" . name
    " Define the variable on the line above
    exec "normal! O" . name . " = "
    " Paste the original selected text to be the variable value
    normal! $p
endfunction
