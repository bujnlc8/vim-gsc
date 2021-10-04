if exists('b:current_syntax')
	finish
endif

syntax match GscAuthor /\[.*\].*/
syntax match GscUrl /http.*/
syntax match GscContent /\%u0001.*/
syntax match GscIntro  /\%u0003.*/
syntax match GscAnnotation   /\%u0004.*/
syntax match GscTranslation   /\%u0005.*/
syntax match GscAppreciation   /\%u0006.*/
syntax match GscMasterComment   /\%u0007.*/
syntax match GscTitle  /\%u0002.*\%u0002/

highlight GscUrl term=underline ctermfg=246 guifg=#898f9e
highlight GscAuthor term=bold ctermfg=137 guifg=#b28761
highlight GscContent term=bold cterm=bold gui=bold
highlight GscTitle term=underline ctermfg=67 guifg=#5496bd
highlight GscAnnotation term=underline ctermfg=168 guifg=#c17b8d
highlight GscIntro term=underline cterm=underline gui=underline
highlight GscAppreciation term=underline ctermfg=37 guifg=#459d90
highlight GscTranslation term=underline cterm=underline gui=underline
highlight GscMasterComment term=bold ctermfg=107 guifg=#7d9761

syntax sync fromstart

let b:current_syntax = 'gsc'
