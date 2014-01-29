" we're not using vi, we're using vim
set nocompatible

" change the mapleader from \ to ,
let mapleader=","

" we want customization based on filetype
filetype plugin on

set scrolloff=2 " allways have two lines of context

" OS X: copy current file into paste buffer
map <leader>pb :!pbcopy < "%"<cr>

" http://vim.wikia.com/wiki/Resize_splits_more_quickly
nnoremap <silent> =+ :exe "vertical resize " . (winwidth(0) * 3/2)<CR>
nnoremap <silent> =- :exe "vertical resize " . (winwidth(0) * 2/3)<CR>

source ~/.vim/plugin/matchit.vim
set cursorline     " see which line I'm on
set laststatus=2   " always have a status bar
set bs=2
set ts=4
set textwidth=78
set nowrap
set ruler
set autowrite
set hlsearch
set hidden
set autoindent
set fenc=utf8
set termencoding=utf8
set incsearch
set showmatch
set smarttab
set complete=.,w,b,u,t " omits ',i'. This avoids full file scans.
set foldenable

" A tab produces a 4-space indentation
set softtabstop=4
set shiftwidth=4
set expandtab

"match ErrorMsg '\%>80v.\+'
"match ErrorMsg '\s\+$'

syntax enable
set background=dark
set t_Co=256 " enable 256 color support
colorscheme solarized

" quickfix for vim errors. See
" http://blogs.perl.org/users/ovid/2010/11/vims-quickfix-mode-and-perl.html
set errorformat+=%m\ at\ %f\ line\ %l\.
set errorformat+=%m\ at\ %f\ line\ %l


" mappings
noremap <leader>w   <esc><C-W><C-W>:res<cr>

noremap <leader>h   :nohl<cr>

" poor man's buffer explorer
noremap <leader>j   :ls<cr>:e#

noremap <leader>pp  :set invpaste<cr>
noremap <leader>np  :set nopaste<cr>
noremap <leader>ls  :!ls $(dirname %)<cr>
noremap <leader>la  :!ls -al $(dirname %)<cr>

" make tab in v mode ident code
vmap <tab> >gv
vmap <s-tab> <gv

" My simplistic git integration. I should probably use fugitive or something
" 'c' stands for 'c'ode. Originally wrote this for CVS years ago, migrated it
" to Subversion and it now works for git.
" ca: code annotate
" cl: code log
" cr: code review
" cd: code commit (you cannot commit without a review)
" c1: find first commit with the current <cword>
noremap <leader>ca :!git annotate %<cr>
noremap <leader>cl :!git log %<cr>
noremap <leader>cr :call SourceReview()<cr>  " git diff
noremap <leader>cc :call SourceCommit()<cr>  " git commit
noremap <leader>c1 :!git log --reverse -p -S<cword> %<cr>

" automatically source the .vimrc file if I change it
" the bang (!) forces it to overwrite this command rather than stack it
au! BufWritePost .vimrc source %

noremap <leader>v  :source ~/.vimrc<cr>
noremap <leader>V  :e ~/.vimrc<cr>

" make sure the backspace key works
if &term=="xterm"
    " this is a "control-v backspace"
    set t_kb=
    fixdel
endif

function! CleverTab() " I need to be cleverer
   if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
      return "\<Tab>"
   else
      return "\<C-N>"
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

let g:last_tick = 0
function! SourceReview()
    :!git diff --color "%"
    let g:last_tick = b:changedtick
endfunction

function! SourceCommit()
    if g:last_tick == b:changedtick
        :!git commit -v "%"
        let g:last_tick = b:changedtick
    else
        echohl WarningMsg
        echo "You cannot commit source code until you review it"
        echohl None
    endif
endfunction

function! XMLMappings()
    noremap <leader>xf :%!xmllint --nonet --format %<cr>
    vnoremap <leader>xf :!xmllint --nonet --format -<cr>
    noremap <leader>xp :call Xpath()<cr>
    noremap <leader>xv :!xmllint --relaxng docs/rest_api/schema/rng/core.rng %<cr>
endfunction

function! RunTestMethod()
    call SavePosition()
"    execute '?^sub.*:.*Test<cr>w"zye:!DIE_ON_FAIL=1 TEST_METHOD="<c-r>z" prove -vl -It/lib %<cr>'
    echo 'help'
    call RestorePosition() 
endfunction

vnoremap <leader>xf  :!xmllint --format -<cr>  " only work in 'visual' mode

function! Xpath()
    let filename = bufname("%")
    let xpath    = input("Enter xpath expression: ")
    let command = "xpath '" . filename . "' '" . xpath . "'"
    echo system(command)
endfunction

au! Bufread,BufNewFile .git/* set textwidth=78

" this is for MySQL's 'edit' command while in the client
au! BufRead,BufNewFile /var/tmp/sql* :call SetMySQL()
function! SetMySQL()
    setf sql
    SQLSetType mysql
    noremap <buffer> ,f :%!formatsql<cr>
endfunction

noremap <silent> ,g :call MyGrep("lib/")<cr>
noremap <silent> ,G :call MyGrep("lib/ t/")<cr>
noremap <silent> ,f :call MyGrep("lib/", expand('<cword>'))<cr>


function! MyGrep(paths, ...)
    let pattern = a:0 ? a:1 : input("Enter pattern to search for: ")

    if !strlen(pattern)
        return
    endif

    " let command = 'ack "' . pattern . '" ' . a:paths .' -l'
    let command = 'git grep -l "' . pattern .'"'
    let bufname = bufname("%")
    let result  = filter(split( system(command), "\n" ), 'v:val != "'.bufname.'"')

    if empty(result)
        echomsg("No files found matching pattern:  " . pattern)
        return
    endif

    " get the list of files
    let file = PickFromList('file', result)

    if strlen(file)
        execute "edit +1 " . file
        execute "/\\v"  . pattern
    endif
endfunction

function! PickFromList( name, list, ... )
    let forcelist = a:0 && a:1 ? 1 : 0

    if 1 == len(a:list) && !forcelist
        let choice = 0
    else
        let lines = [ 'Choose a '. a:name . ':' ] 
            \ + map(range(1, len(a:list)), 'v:val .": ". a:list[v:val - 1]')
        let choice  = inputlist(lines)
        if choice > 0 && choice <= len(a:list)
            let choice = choice - 1
        else
            let choice = choice - 1
        endif
    end

    return a:list[choice]
endfunction

" http://vim.wikia.com/wiki/Display_output_of_shell_commands_in_new_window
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        " let expanded_part = fnameescape(expand(part))
        let expanded_part = expand(part)
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright vertical new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:    ' . a:cmdline)
  call setline(2, 'Expanded Form:  ' .expanded_cmdline)
  call setline(3,substitute(getline(2),'.','=','g'))
  execute '$read !'. expanded_cmdline
  setlocal nomodifiable
  1
endfunction


