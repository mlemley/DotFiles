if exists("g:actionscript_ftplugin")
    finish
endif

let g:actionscript_ftplugin = 1
let s:as_template_path = $HOME . "/.vim/templates/actionscript/"
let s:use_purmvc = 1
let s:use_agi_puremvc = 0
let s:_dict = {}
let s:filename = ""

" create the correct template based off of the name of the new file

function s:NewASFile()
    let l:filename = s:GetFilename()
    let s:filename = l:filename
    call s:LoadGenericVars()
    if match(l:filename, "\\C^[A-Z]") == 0
        if s:use_purmvc == 1
            call s:NewPureMVCfile(l:filename)
        else
            call s:CreateClassFile()
        endif
    else
        if match(l:filename, "\\C[_]") == -1
            call s:SetNewFileTemplate("function_file_template")
            let s:_dict['__typecast__'] = 'void'
        else
            call s:SetNewFileTemplate("namespace_template")
            call s:LoadNamespaceVars(l:filename)
        endif
    endif
    call s:ReplaceTemplateVars()
    call s:HighlightReplaceVars()
    let s:_dict = {}
endfunction

function s:NewPureMVCfile(filename)
    if match(a:filename, "\\CMacroCommand") > 0
        call s:SetNewFileTemplate('puremvc_macrocommand_template')
    elseif match(a:filename, "\\CCommand") > 0
        call s:SetNewFileTemplate('puremvc_command_template')
    elseif match(a:filename, "\\CMediator") > 0
        call s:SetNewFileTemplate('puremvc_mediator_template')
    elseif match(a:filename, "\\CProxy") > 0
        call s:SetNewFileTemplate('puremvc_proxy_template')
        call s:LoadProxyVars(a:filename)
    else
        call s:CreateClassFile()
    endif
endfunction

function g:InsertProperty()
    let l:current_pos = getpos('.')
    call s:SetTemplate("property_template")

    if search("\/\/  Properties") < 1
        call s:SetTemplate("property_head_template")
        execute "normal 6dd2kp"
    endif

    call s:HighlightReplaceVars()
    call setpos('.', current_pos)
endfunction

function s:CreateClassFile()
    call s:SetNewFileTemplate("class_file_template")
endfunction

function s:HighlightReplaceVars()
    syn match Todo "%\w\+%" containedIn=ALL
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

function s:LoadProxyVars(filename)
    let l:prefix = ""
    let l:counter = 0
    let l:length = len(a:filename) - 5
    while l:counter < l:length
        let l:prefix = l:prefix . a:filename[l:counter]
        let l:counter = l:counter + 1
    endwhile
    let l:model = "I" . l:prefix . "Model"
    let s:_dict["__model_interface__"] = l:model
endfunction

function s:LoadNamespaceVars(filename)
    let l:peaces = split(a:filename, '_')
    let s:_dict["__prefix__"] = l:peaces[0]
    let s:_dict["__namespace__"] = l:peaces[1]
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

function s:SetTemplate(template)
    let l:template_path =  s:as_template_path . a:template
    execute 'r ' . l:template_path
endfunction

function s:SetNewFileTemplate(template)
    call s:SetTemplate(a:template)
    execute 'normal ggdd'
endfunction

function s:IsNewFile()
    let l:newFile = 0
    if search('^.$') == 0
        let l:newFile = 1
    endif
    return l:newFile
endfunction

function s:Setup()
    if s:IsNewFile() == 1
        call s:NewASFile()
    endif
    map <F4> <ESC>/%\w.\{-1,}%<cr>
    "  -- was joined deleted word c/%/e<cr>
    map <F6> :call g:InsertProperty()<cr>
endfunction

function s:CleanUp()
    unmap <F4>
    unmap <F6>
endfunction


let s:currentPackage = ''

au BufNewFile *.as call s:NewASFile()
au BufEnter *.as call s:Setup()
au BufLeave *.as call s:CleanUp()
au BufEnter *.as call s:HighlightReplaceVars()
au InsertEnter *.as call s:HighlightReplaceVars()
au InsertLeave *.as call s:HighlightReplaceVars()
