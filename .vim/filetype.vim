if exists('g:did_load_filetypes')
    finish
endif
let g:did_load_filetypes = 1

augroup filetypedetect
    autocmd! BufNewFile,BufRead *.tt         setf tt2html
    autocmd! BufNewFile,BufRead wrapper      setf tt2html
    autocmd! BufNewFile,BufRead /tmp/sql*    setf mysql " syntax highlighting in mysql editing
    autocmd! BufRead,BufNewFile *.pl         setfiletype perl
    autocmd! BufRead,BufNewFile *.pm         setfiletype perl
    autocmd! BufRead,BufNewFile *.yml        setfiletype yaml
    autocmd! BufRead,BufNewFile *.inc        setfiletype tmpl
    autocmd! BufRead,BufNewFile *.tmpl       setfiletype tmpl
    autocmd! BufRead,BufNewFile *.t          call s:PerlTestMappings()
    autocmd! BufRead,BufNewFile *.py         call s:PythonMappings()
augroup END

augroup CPPprog
   au!
   "-----------------------------------
   " GENERAL SETTINGS
   "-----------------------------------
   au BufRead,BufNewFile,BufEnter             *.cpp,*.c,*.h,*.hpp   set nolisp
   au BufRead,BufNewFile,BufEnter             *.cpp,*.c,*.h,*.hpp   set filetype=cpp
   au FileType                                *.c,*.pl,*.pm,*.t,*.cpp,*.h  set nocindent smartindent
   au FileType                                *.c,*.cpp             set cindent
   au BufRead,BufNewFile,BufEnter             *.cpp                 let g:qt_syntax=1
   " turn on qt syntax highlighting (a plugin)
   au BufNewFile,BufRead,BufEnter             *.c,*.h,*.cpp,*.hpp   let c_space_errors=1
augroup END

augroup filetype
  au! BufRead,BufNewFile,BufEnter *Makefile*,*makefile*,*.mk set filetype=make
augroup END
" In Makefiles, don't expand tabs to spaces, since we need the actual tabs
autocmd FileType make set noexpandtab

function! s:PythonMappings()
    noremap <buffer> <leader>r :!python "%"<CR>
endfunction

function! s:PerlTestMappings()

    " run the current test with prove
    noremap <buffer> <leader>r :!prove -vl %<cr>
    " run the current test with prove
    noremap <buffer> <leader>t :!prove -vl %<CR>

    " run the tests in current buffer. Split window and put output in new
    " buffer
    noremap <buffer> <leader>T :call PerlTest(bufname('%'))<CR>

    " turns all comments into explain() statements. Requires Test::Most
    noremap <buffer> <leader>fp :%s/^\(\s*\)# \(.*\)/\1explain("\2");<cr>
    noremap <leader>tb :call RunTestsInBuffers()<cr>
endfunction
