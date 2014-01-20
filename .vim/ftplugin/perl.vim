" Vim filetype plugin file
"
" Language   :  Perl
" Plugin     :  perl-support.vim (version 3.2.1)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  29.08.2006
"
" ----------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("g:did_PERL_ftplugin")
  finish
endif
let g:did_PERL_ftplugin = 1

setlocal iskeyword+=:

" Adds a Data::Dumper call and positons your cursor, in insert mode, in the
" middle of the Dumper() parens
noremap <leader>dd  :call AddDataDumper()<cr>
vnoremap <leader>e :call ExtractSub()<cr>
noremap <leader>pv  :!echo <cword> version `$HOME/bin/pversion '<cword>'`<cr>
noremap <leader>pd  :!perldoc "%" <bar> less -R<cr>
nnoremap <leader>pt  :%!perltidy -q<cr> " only work in 'normal' mode
vnoremap <leader>pt  :!perltidy -q<cr>  " only work in 'visual' mode
noremap <leader>d   :!perl -d %<cr>
noremap <leader>rr  :!time ~/bin/rebuild<cr>
noremap <leader>s   :!perl ~/bin/subs %<cr>
noremap <leader>S   :!~/bin/unused_subs %<cr>
noremap <leader>c   :!time perlc %<cr>

"
" Jump to exactly where I need to go
noremap <leader>gc  :call GotoCorresponding(expand('<cword>'))<cr>
noremap <leader>gg  :call GotoCorresponding(expand("%"))<cr>
noremap <leader>gm  :call GotoModule(expand('<cword>'))<cr>
noremap <leader>gp  :call GotoPod(expand('<cword>'))<cr>
noremap <leader>gs  :call GotoSub(expand('<cword>'))<cr>

" run the code in the current buffer
noremap <leader>r   :!time perl %<cr>

" run the selected code.
" this strange little puppy takes the Perl highlighted in visual mode and runs
" it, outputting the output after the highlighted lines. Originally written
" for my book so I could write a snippet of code inline, highlight it, and
" insert output directly into the book's text.
vnoremap <silent> ,r :!perl ~/bin/validperl<cr>
" This makes the status line work *only* for the first perl file loaded, but
" if I don't do it this way, the statusline has this check appended each time
" the buffer is visited.  How to fix this?

"if ! exists("g:did_perl_statusline")
    setlocal statusline+=%(\ %{PerlCurrentSubName()}%)
    setlocal statusline+=%=
    setlocal statusline+=%f\ 
    setlocal statusline+=%P\ 
"    let g:did_perl_statusline = 1
"endif

function! PerlTest(testfile)
    new +setf\ TAPVerboseOutput
    execute '%! prove -vl -It/lib ' . a:testfile
endfunction

function! PerlMappings()
    map <buffer> ,cv :call Coverage()<cr>
    map <buffer> ,r  :!perl %<cr>
    noremap K :!perldoc -t <cword> <bar><bar> perldoc -t -f <cword><cr>
"    setlocal foldexpr=GetPerlFold()
"    setlocal foldmethod=expr 
endfunction

function! PerlCurrentSubName()
    let s:currline = line('.')
    let s:currcol = col('.')
    normal $ 
    let [s:line, s:column] = searchpos('^\s*sub\s\+\zs\(\w\+\)','bcW')
    if (s:line != 0)
        let s:subname = getline(s:line)
    else
        let s:subname = '(not in sub)'
    endif
    call cursor(s:currline, s:currcol)
    return s:subname
endfunction

"
" highlight some lines, hit <leader>e and it will prompt you for a subroutine
" name. Then it will insert a subroutine at the current line (embedded in your
" code). You'll need to do some editing to clean it up.
"
function! ExtractSub() range
    " yank selection into x
    "normal gv"xy

    let subname = input("Sub name: ")

    let code    = shellescape(join(getline(a:firstline, a:lastline),"\n"))
    " put extracted sub/method into the x register)
    let @x = system('echo '. code ." | ~/bin/extract --subname=" . subname.' '.code)

    " re-select and delete
    normal gvd
    " paste x into visual areaq
    normal "xP 
endfunction

" if I'm in a module, edit its tests. If I'm in a test, edit the module
function! GotoCorresponding(module)
    let file = system("perl /Users/curtispoe/bin/get_corresponding ".a:module)
    if !empty(file)
        execute "edit " . file
    else
        echoerr("Cannot find corresponding file for: ".a:module)
    endif
endfunction

" strict
let g:perl_path_to = {}
function! GotoModule(module)
    let files  = []

    if !has_key(g:perl_path_to, a:module)
        let g:perl_path_to[a:module] = []

        let lib    = split(system("perl -MFile::Spec::Functions=rel2abs -le 'print join $/ => grep { !$found{rel2abs($_)}++ } q{lib}, q{t/lib}, @INC'"), "\n")
        let extra  = split(system("cat .libcustom"),"\n")

        if !empty(extra)
            let lib = lib + extra
        endif

        let module = substitute(a:module, '::', '/', 'g') . '.pm'

        for path in lib
            let path = path . '/' . module
            if filereadable(path)
                let g:perl_path_to[a:module] = g:perl_path_to[a:module] + [ path ]
            endif
        endfor
    endif

    let paths = g:perl_path_to[a:module]
    if empty(paths)
        echomsg("Module '".a:module."' not found")
    else
        let file = PickFromList('file', paths)
        execute "edit " . file
    endif
endfunction

function! GotoPod(podname)
    let file   = system("perldoc -l ". a:podname)

    if !empty(file)
        execute "edit " . file
    endif
endfunction

function! GotoSub(subname)
    let files  = []

    let paths = split(system("git grep -l 'sub \s*".a:subname."' lib t"), "\n")

    if empty(paths)
        echomsg("Subroutine '".a:subname."' not found")
    else
        let file = PickFromList('file', paths)
        execute "edit +1 " . file
        execute "/sub\\s\\+"  . a:subname . "\\>"
    endif
endfunction

function! AddDataDumper()
    let number = line(".")
    call append(number + 0, "use Data::Dumper::Simple;")
    call append(number + 1, "local $Data::Dumper::Indent   = 1;")
    call append(number + 2, "local $Data::Dumper::Sortkeys = 1;")
    call append(number + 3, "print STDERR Dumper( )")
    execute ":call cursor(" . (number+4) . ",21)"
    execute ":startinsert"
endfunction

function! RunTestsInBuffers()
    let i = 1
    let tests = ''
    while (i <= bufnr("$"))
        let filename = bufname(i)
        if match(filename, '\.t$') > -1
            let tests = tests . ' "' . filename . '"'
        endif
        let i = i+1
    endwhile
    if !strlen(tests)
        echo "No tests found in buffers"
    else
        execute ':!prove -l -It/lib ' . tests
    endif
endfunction
set ruler

" fix this someday
function! Coverage()
    let filename = bufname('%')

    if ! exists("g:perl_coverx_prefix")
        " we'll file this later
        let g:perl_coverx_prefix = 'blib/'
    endif

    let istest = match(filename, '\.t$') > -1 ? 1 : 0

    if istest
        let command = 'covered by --test_file="'. filename .'" | sed -e "s/^blib\///"'
    else
        let command = 'covered covering --source_file="'. g:perl_coverx_prefix . filename .'"'
    end

echo command
return
    let result  = split( system(command), "\n" )
    if empty(result)
        echomsg "No files found: ". command
    else
        let file = PickFromList('file',result)
        execute "edit " . file
    endif
endfunction

