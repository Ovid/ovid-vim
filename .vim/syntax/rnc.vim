" Vim syntax file
" Language:	RELAX NG Compact Syntax
" Maintainer:	Hans Fugal <hans@fugal.net>
" Last Change:	$Date: 2003/06/22 03:32:14 $
" $Id: rnc.vim,v 1.7 2003/06/22 03:32:14 fugalh Exp $

if version < 600
    syntax clear
elseif exists ("b:current_syntax")
    finish
endif

" add the character '-' and '.' to iskeyword.
set iskeyword+=45,46 

" Comments
syn match Comment /^\s*#[^#].*$/
syn match Documentation /^\s*##.*$/

" Literals
syn region literalSegment start=/"/ end=/"/ 

syn match patternSpecial /[,&|?*+\\]/
syn match Identifier /\k\+\s*\(&=\|=\||=\)\@=/ nextgroup=assignMethod
syn match assignMethod /&=\|=\||=/
syn match namespace /\k\+\(:\(\k\|\*\)\)\@=/
syn region Annotation excludenl start=/\[/ end=/\]/ contains=ALLBUT,Identifier,patternName

" named patterns (element and attribute)
syn keyword patternKeyword element attribute nextgroup=patternName skipwhite skipempty 
syn match patternName /\k\+/ contained

" Keywords
syn keyword patternKeyword  list mixed parent empty text notAllowed externalRef grammar
syn keyword grammarContentKeyword  div include
syn keyword startKeyword  start
syn keyword datatypeNameKeyword  string token
syn keyword namespaceUriKeyword  inherit
syn keyword inheritKeyword  inherit
syn keyword declKeyword  namespace default datatypes

" Links
hi link patternKeyword keyword
hi link patternName Identifier
hi link grammarContentKeyword keyword
hi link startKeyword keyword
hi link datatypeNameKeyword keyword
hi link namespaceUriKeyword keyword
hi link inheritKeyword keyword
hi link declKeyword keyword

hi link literalSegment String
hi link Documentation Comment

hi link patternSpecial Special
hi link namespace Type

let b:current_syntax = "rnc"
" vim: ts=8 sw=4 smarttab
