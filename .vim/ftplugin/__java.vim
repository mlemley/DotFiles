if exists("g:javaScriptsLoaded_ftplugin")
    finish
endif

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden

" Remember more commands and search history
set history=1000

let g:javaScriptsLoaded_ftplugin = 1

let s:compCmd = ""
let s:target = " compile"

function JumpToError()
    "echo getqflist()
    if getqflist() != []
        let showRedBar = 0
        for error in getqflist()
            if error['valid']
                silent cc!
                if l:showRedBar == 0
                    call RedBar()
                    let l:showRedBar = 1
                endif
                echo "line: " . error['lnum'] . " error: " .  substitute(error['text'], '^ *', '', 'g')
            endif
        endfor

        if l:showRedBar == 0
            call GreenBar()
            echo "Compiled Successfully"
        endif
    else
        call GreenBar()
        echo "Compiled Successfully"
    endif
endfunction

function s:SetMakePrg()
    let l:path = split(expand("%:p"), "/")
    let l:foundSource = 0
    let l:bin = "/"

    for l:part in l:path
        if l:foundSource == 1
            break
        endif

        if l:part == "src"
            let l:foundSource = 1
            let l:bin = l:bin . "build.xml"
        else
            let l:bin = l:bin . part . "/"
        endif
    endfor

    let s:compCmd = " -f " . l:bin

endfunction

function s:Compile()
    silent ! echo
    silent ! echo -e "\033[1;36mCompiling Android Application\033[0m"
    silent w
    exec "make " . s:compCmd . s:target
endfunction

function g:Compile()
    let s:target = " compile"
    call s:Compile()
endfunction

function g:Install()
    let s:target = " install"
    call s:Compile()
endfunction


function s:SetEFM()
    set efm=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
    setlocal makeprg=ant\ -l\ .ant.log
    set makeef=.ant.log
    set shellpipe=
    call s:SetMakePrg()
    map <F9> :call g:Compile()<cr>:redraw<cr>:call JumpToError()<cr>
    map <F12> :call g:Install()<cr>:redraw<cr>:call JumpToError()<cr>
endfunction

au BufEnter *.java call s:SetEFM()
au BufRead *.java call s:SetEFM()
au BufNewFile  *.java call s:SetEFM()



""""""   TEMPLATING STUFF """""""""""""

function s:NewFile()
    let l:filename = s:GetFilename()
    let s:filename = l:filename
    call s:LoadGenericVars()
    if match(l:filename, "\\C^[A-Z]") == 0
        if match(l:filename, "\\CActivity") > 0
            call sSetNewFileTemplate('activity_template')
        else
            call s:SetNewFileTemplate("class_file_template")
        endif
    endif
    call s:ReplaceTemplateVars()
    call s:HighlightReplaceVars()
    let s:_dict = {}
endfunction

function s:LoadGenericVars()
    let s:_dict["__name__"] = s:GetFilename()
    let s:_dict["__package__"] = s:BuildPackage()
endfunction

function s:GetFilename()
    let l:parts = split(@%, '/')
    let l:length = len(l:parts)
    let l:fname = l:parts[l:length -1]
    let l:fsplit = split(l:fname, '\.')
    return l:fsplit[0]
endfunction

function s:BuildPackage()
    let l:path = split(expand("%:p"), '/')
    let l:package = ""
    let l:foundSrc = 0
    let l:counter = 1
    let l:times = len(l:path)
    for l:part in l:path
        if l:foundSrc == 1
            if l:counter != l:times
                let l:package = l:package . l:part
                if l:counter <= l:times -2
                    let l:package = l:package . '.'
                endif
            endif
        endif
        if l:part == "src"
            let l:foundSrc = 1
        endif
        let l:counter = l:counter + 1
    endfor
    let s:currentPackage = l:package
    return l:package
endfunction

function s:ReplaceTemplateVars()
    for [l:key, l:value] in items(s:_dict)
        if len(l:value) > 0
            execute "%s/" . l:key . "/" . l:value . "/e"
        else
            execute "%s/ " . l:key . "//e"
        endif
    endfor
endfunction

function s:HighlightReplaceVars()
    syn match Todo "%\w\+%" containedIn=ALL
endfunction

