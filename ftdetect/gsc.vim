au Filetype gsc set isprint=@,161-255,1-7
au BufWinEnter,Filetype gsc match  Conceal /[\u0001\u0002\u0003\u0004\u0005\u0006\u0007]/
au BufNewFile,BufRead *.gsc set filetype=gsc
