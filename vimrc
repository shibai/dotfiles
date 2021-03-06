let s:host_vimrc = $HOME . '/.vimrc-envImprove'
if filereadable(s:host_vimrc)
  execute 'source ' . s:host_vimrc
endif
set nocompatible
set number
set backspace=indent,eol,start
set ignorecase
set cursorline
set paste
set splitright
syntax on
set tw=0
set expandtab
set tabstop=4
cmap w!! w !sudo tee > /dev/null %

" Make deletion work properly inside screen
imap ^? ^H

set t_kb=
fixdel

" Remap Shift-Enter to ESC, allowing easier exit from insert mode
:inoremap <S-CR> <Esc>

" Auto-close xml/html tags
"iabbrev </ </<C-X><C-O>
