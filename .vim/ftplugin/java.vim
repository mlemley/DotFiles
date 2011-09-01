if exists("g:javaScriptsLoaded_ftplugin")
    finish
endif

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden
let mapleader=","

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
            let l:bin = l:bin . "../build.xml"
        else
            let l:bin = l:bin . part . "/"
        endif
    endfor

    let s:compCmd = " -f " . l:bin

endfunction

function s:CompileApp()
    silent ! echo
    silent ! echo -e "\033[1;36mCompiling Android Application\033[0m"
    silent w
    exec "make " . s:compCmd . s:target
endfunction

function g:CompileJava()
    let s:target = " compile"
    call s:CompileApp()
endfunction

function g:Install()
    let s:target = " install"
    call s:CompileApp()
endfunction

function s:SetEFM()
    set efm=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
    setlocal makeprg=ant\ -l\ .ant.log
    set makeef=.ant.log
    set shellpipe=
    call s:SetMakePrg()
    map <F9> :call g:CompileJava()<cr>:redraw<cr>:call JumpToError()<cr>
    map <F12> :call g:Install()<cr>:redraw<cr>:call JumpToError()<cr>
endfunction

au BufEnter *.java call s:SetEFM()
au BufRead *.java call s:SetEFM()
au BufNewFile  *.java call s:SetEFM()

let s:as_template_path = $HOME . "/.vim/templates/java/"
let s:_dict = {}
let s:filename = ""

" create the correct template based off of the name of the new file

function s:NewJavaFile()
    let l:filename = s:GetFilename()
    let s:filename = l:filename
    call s:LoadGenericVars()

    if match(l:filename, "\\CTest") > 0
        call s:SetNewFileTemplate('test_case_template')
    elseif match(l:filename, "\\CActivity") > 0
        call s:SetNewFileTemplate('activity_class_template')
    elseif match(l:filename, "\\CProvider") > 0
        call s:SetNewFileTemplate('provider_class_template')
    else
        call s:SetNewFileTemplate("class_template")
    endif

    call s:ReplaceTemplateVars()
    call s:HighlightReplaceVars()
    let s:_dict = {}
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

function s:GetFileLocation()
    return split(expand("%:p"), '/')
endfunction 

function s:BuildPackage()
    let l:path = split(expand("%:p"), '/')
    let l:package = ""
    let l:foundSrc = 0
    let l:lookforJava = 0
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

        if l:counter < len(l:path)

            if l:part == "src" && (l:path[l:counter] != "main" && l:path[l:counter] != "test") 
                let l:foundSrc = 1
            elseif l:part == "src" && l:path[l:counter] == "main"
                let l:lookforJava = 1
            elseif l:part == "src" && l:path[l:counter] == "test"
                let l:lookforJava = 1
            elseif l:path[l:counter] == "test"
                let l:lookforJava = 1
            elseif l:lookforJava == 1 && l:part == "java"
                let l:foundSrc = 1
            endif
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

function g:CreateMemeberVariable()
    let l:type = input("Var type: ")
    let l:name = input("Var name: ")
    let l:line = 'private ' . l:type . ' ' . l:name . ';'
    return l:line
endfunction

function g:CreateMethod()
    let l:accessModifier = input("access modifier: ")
    let l:returnType = input("return type: ")
    let l:name = input("Var name: ")
    let l:Args = input("Args: ")
    let l:line = l:accessModifier . ' ' . l:returnType . ' ' . l:name . '('
    return l:line
endfunction

function s:Setup()
    if s:IsNewFile() == 1
        call s:NewJavaFile()
    endif
    "map ,, :call OpenCounterPart()<cr>
    map <leader>, :call OpenCounterPart()<cr>
    map <leader>t :call ExecuteTest()<cr>

    "map <F4> <ESC>/%\w.\{-1,}%<cr>
    "  -- was joined deleted word c/%/e<cr>
endfunction

function s:CleanUp()
endfunction

function s:IsNewFile()
    let l:newFile = 0
    if search('^.$') == 0
        let l:newFile = 1
    endif
    return l:newFile
endfunction

let s:currentPackage = ''

function s:OpenMainClass() 
    let l:path = s:GetFileLocation()
    let l:path[-1] = substitute(s:GetFilename(), "Test", ".java", "") 
    let l:mainPath = ""

    for l:part in path
        if l:part == "test"
            let l:part = "main"
        endif
        let l:mainPath = l:mainPath . "/" . l:part
    endfor

    let l:mainDirs = split(l:mainPath, "/")
    let l:mainDir = "/" . join(l:mainDirs[0:-2], "/")
    if !isdirectory(l:mainDir)
        call mkdir(l:mainDir, "p", 0755)
    endif
    :execute "vsp " . l:mainPath
endfunction

function s:OpenTestClass() 
    let l:path = s:GetFileLocation()
    let l:testPath = ""
    let l:path[-1] = substitute(l:path[-1], "\.java", "Test\.java", "")

    for l:part in path
        if l:part == "main"
            let l:part = "test"
        endif
        let l:testPath = l:testPath . "/" . l:part
    endfor

    let l:testDirs = split(l:testPath, "/")
    let l:testDir = "/" . join(l:testDirs[0:-2], "/")
    if !isdirectory(l:testDir)
        call mkdir(l:testDir, "p", 0755)
    endif
    :execute "vsp " . l:testPath
endfunction

function s:GetSourceFile()
    let l:filename = s:GetFilename()
    let l:path = "/" . join(s:GetFileLocation()[:-2], "/") . "/" 
    if match(l:filename, "Test") > 0
        let l:filename = substitute(l:filename, 'Test', '\.java', '')
        let l:path = substitute(l:path, 'test', 'main', '')
    else
        let l:filename = l:filename . "\.java"
    endif
    return l:path . l:filename
endfunction

function s:GetTestFile()
    let l:filename = s:GetFilename()
    let l:path = "/" . join(s:GetFileLocation()[:-2], "/") . "/" 
    if match(l:filename, "Test") <= 0
        let l:filename = l:filename . "Test\.java"
        let l:path = substitute(l:path, 'main', 'test', '')
    else
        let l:filename = l:filename . "\.java"
    endif
    return l:path . l:filename
endfunction

function s:GetTestFilename()
    let l:filename = s:GetFilename()
    if match(l:filename, "Test") <= 0
        let l:filename = l:filename . "Test"
    endif
    return l:filename
endfunction

function s:GetTargetDir()
    let l:path = s:GetFileLocation()
    let l:targetDir = ""
    let foundSrc = 0
    for l:part in l:path
        if l:part != "src" && foundSrc == 0
            let l:targetDir = l:targetDir . "/" . l:part
        else 
            break
        endif
    endfor
    
    let l:targetDir =  l:targetDir . "/" . "target"
    return l:targetDir
endfunction

function s:GetSourcesOutPut()
    return s:GetTargetDir() . "/classes/"
endfunction

function s:GetTestOutPut()
    return s:GetTargetDir() . "/test-classes/"
endfunction

function s:CompileSource()
    let l:cmd = "javac -classpath " . s:GetLibs() . " -d " . s:GetSourcesOutPut() . " " . s:GetSourceFile()
    return system(l:cmd)
endfunction

function s:CompileTest()
    let l:cmd = "javac -classpath " . s:GetLibs() . " -d " . s:GetTestOutPut() . " " . s:GetTestFile()
    return system(l:cmd)
endfunction

function s:SanitizeJUnitOuput(output)
    let l:lines = split(a:output, "\n")
    let l:wanted = []
    for l:line in l:lines
        if !(match(l:line, "at ") >= 0) && !(match(l:line, "JUnit") >= 0)
            call add(l:wanted, l:line)
        endif 
    endfor
    return join(l:wanted, "\n")
endfunction

function ExecuteTest()
    let l:compileResults = s:CompileSource()
    if len(l:compileResults) > 0
        call RedBar(l:compileResults)
    endif

    if len(l:compileResults) == 0
        let l:compileResults = s:CompileTest()
        if len(l:compileResults) > 0
            call RedBar(l:compileResults)
        endif
    endif

    if len(l:compileResults) == 0
        let l:package = s:BuildPackage() . "." . s:GetTestFilename()
        let cmd = "java -classpath " . s:GetLibs() . " org.junit.runner.JUnitCore " . l:package 
        let l:testResults = system(cmd)
        if match(l:testResults, "failure") > 0
            call RedBar(s:SanitizeJUnitOuput(l:testResults))
            call RedBar("")
        else
            call GreenBar(join(split(l:testResults, "\n"), " "))
        endif
    endif
endfunction

function s:GetLibs()
    let l:path = s:GetFileLocation()
    let l:libsDir = ""
    let l:targetDir = ""
    let foundSrc = 0
    for l:part in l:path
        if l:part != "src" && foundSrc == 0
            let l:targetDir = l:targetDir . "/" . l:part
        else 
            break
        endif
    endfor
    
    let l:targetDir =  l:targetDir . "/" . "target"
    let l:libsDir =  l:targetDir . "/" . "dependency"
    let l:jars = system("find *.jar " . l:libsDir)
    let l:strJars = ""
    let l:goodjars = []

    for l:jar in split(jars, "\n")[1:]
        if match(l:jar, "\.jar") > 0 
            call add(l:goodjars, l:jar)
        endif
    endfor
    call add(l:goodjars, l:targetDir . "/classes/")
    call add(l:goodjars, l:targetDir . "/test-classes/")
    return join(l:goodjars, ":")
endfunction

function OpenCounterPart() 
    let l:filename = s:GetFilename()
    if match(s:GetFilename(), "\\CTest") > 0
        call s:OpenMainClass()
    else
        call s:OpenTestClass()
    endif 
endfunction

au BufNewFile *.java call s:NewJavaFile()
au BufEnter *.java call s:Setup()
au BufLeave *.java call s:CleanUp()
au BufEnter *.java call s:HighlightReplaceVars()
au InsertEnter *.java call s:HighlightReplaceVars()
au InsertLeave *.java call s:HighlightReplaceVars()
