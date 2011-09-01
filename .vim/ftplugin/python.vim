if exists("g:mlPythonFTPlugin")
    finish
endif

let g:mlPythonFTPlugin = 1
let python_highlight_builtins = 1

" shortcut maps
unmap <F8>
map <F8> :sh<Cr>
unmap <F12>
map <F12> :!ipython<Cr>
