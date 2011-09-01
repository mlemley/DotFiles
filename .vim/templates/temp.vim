if exists("g:as_loaded")
    finish
endif

"script vars
let g:as_loaded = 1
let s:as_template_path = $HOME . "/.vim/helpers/actionscript/"
let s:use_purmvc = 1
let s:use_agi_puremvc = 0
let s:_dict = {}

map <F4> <ESC>/%\w.\{-1,}%<cr>
"  -- was joined deleted word c/%/e<cr>
map <F6> :call InsertProperty()<cr>

" create the correct template based off of the name of the new file

function NewASFile()
    let filename = GetFilename()
    call LoadGenericVars()
    if match(filename, "\\C^[A-Z]") == 0
        if s:use_purmvc == 1
            if match(filename, "\\CMacroCommand") > 0
                call SetNewFileTemplate('puremvc_macrocommand_template')
            elseif match(filename, "\\CCommand") > 0
                call SetNewFileTemplate('puremvc_command_template')
            elseif match(filename, "\\CMediator") > 0
                call SetNewFileTemplate('puremvc_mediator_template')
            elseif match(filename, "\\CProxy") > 0
                call SetNewFileTemplate('puremvc_proxy_template')
                call LoadProxyVars(filename)
            else
                call CreateClassFile()
            endif
        else
            call CreateClassFile()
        endif
    else
        if match(filename, "\\C[_]") == -1
            call SetNewFileTemplate("function_file_template")
            let s:_dict['__typecast__'] = 'void'
        else
            call SetNewFileTemplate("namespace_template")
            call LoadNamespaceVars(filename)
        endif
    endif
    call ReplaceTemplateVars()
    call HighlightTODOreplaceVars()
    let s:_dict = {}
endfunction

function InsertProperty()
    let current_pos = getpos('.')
    call SetTemplate("property_template")
    if search("\/\/  Properties") < 1
        call SetTemplate("property_head_template")
        execute "normal 6dd2kp"
    endif
    call HighlightTODOreplaceVars()
    call setpos('.', current_pos)
endfunction

function CreateClassFile()
    call SetNewFileTemplate("class_file_template")
endfunction

function HighlightTODOreplaceVars()
    syn match Todo "%\w\+%" containedIn=ALL
endfunction

function ReplaceTemplateVars()
    for [key, value] in items(s:_dict)
        if len(value) > 0
            execute "%s/" . key . "/" . value . "/e"
        else
            execute "%s/ " . key . "//e"
        endif
    endfor
endfunction

function LoadProxyVars(filename)
    let prefix = ""
    let counter = 0
    let length = len(a:filename) - 5
    while counter < length
        let prefix = prefix . a:filename[counter]
        let counter = counter + 1
    endwhile
    let model = "I" . prefix . "Model"
    let s:_dict["__model_interface__"] = model
endfunction

function LoadNamespaceVars(filename)
    let peaces = split(a:filename, '_')
    let s:_dict["__prefix__"] = peaces[0]
    let s:_dict["__namespace__"] = peaces[1]
endfunction

function LoadGenericVars()
    let s:_dict["__name__"] = GetFilename()
    let s:_dict["__package__"] = BuildPackage()
endfunction

function GetFilename()
    let parts = split(@%, '/')
    let length = len(parts)
    let fname = parts[length -1]
    let fsplit = split(fname, '\.')
    return fsplit[0]
endfunction

function BuildPackage()
    let path = split(expand("%:p"), '/')
    let package = ""
    let foundSrc = 0
    let counter = 1
    let times = len(path)
    for part in path
        if foundSrc == 1
            if counter != times
                let package = package . part
                if counter <= times -2
                    let package = package . '.'
                endif
            endif
        endif
        if part == "src"
            let foundSrc = 1
        endif
        let counter = counter + 1
    endfor
    let s:currentPackage = package
    return package
endfunction

function SetTemplate(template)
    let template_path =  s:as_template_path . a:template
    execute 'r ' . template_path
endfunction

function SetNewFileTemplate(template)
    call SetTemplate(a:template)
    execute 'normal ggdd'
endfunction

let s:currentPackage = ''
