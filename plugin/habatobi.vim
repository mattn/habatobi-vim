scriptencoding utf-8

let s:cursor = ''

function! s:cursor_on(f)
  if s:cursor == ''
    redir => s:cursor
    silent! hi Cursor
    redir END
    let s:cursor = substitute(matchstr(s:cursor, 'xxx\zs.*'), "\n", ' ', 'g')
  endif
  if a:f
    exe "hi Cursor ".s:cursor
  else
    hi Cursor term=NONE ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
  endif
endfunction

function! s:start()
  silent edit `='==幅飛び=='`
  setlocal buftype=nowrite
  setlocal noswapfile
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal nonumber
  setlocal nolist
  setlocal nowrap
  setlocal nocursorline
  setlocal nocursorcolumn
  syn match HabatobiGreen '\~'
  hi HabatobiGreen ctermfg=black ctermbg=green guifg=black guibg=green
  syn match HabatobiBar '\^'
  hi HabatobiBar ctermfg=red ctermbg=red guifg=red guibg=red
  syn match HabatobiPower '^=.*'
  hi HabatobiPower ctermfg=red ctermbg=yellow guifg=red guibg=yellow

  for i in range(1, winheight('.'))
    call setline(i, repeat(' ', 80))
  endfor
  call setline(18, repeat("~", 30) . '^' . repeat("~", 48))
  let power = 0
  let state = 0
  let x = 0
  call s:cursor_on(0)
  while 1
    let c = getchar(0)
    if c == 27 || c == 113
      break
    endif
    if state == 3
	elseif state == 2
      let dy = 40
      let jx = x * 100
      let jy = 1600
      while dy >= -40
        call setline(jy / 100,   repeat(" ", jx / 100) . "           ")
        call setline(jy / 100+1, repeat(" ", jx / 100) . "           ")
        let jx += power
        let jy -= dy
        let dy -= 1
        call setline(jy / 100,   repeat(" ", jx / 100) . "  ヽｾｲﾔｧ!ノ")
        call setline(jy / 100+1, repeat(" ", jx / 100) . "(; ﾟДﾟ)   ")
        sleep 10ms
        redraw
      endwhile
      call setline(16, repeat(" ", jx / 100) . "   ヽｹﾞﾌｯノ")
      call setline(17, repeat(" ", jx / 100) . "(;´Д`)   ")
	  echomsg "記録: " . printf("%.02fメートル", str2float(jx/100 - 23) / 10)
      let state = 3
    else
      if c == 32
        let state = 2
	  elseif state == 0 && c == 106
        let power += 5
        let state = 1
        let x += 1
      elseif state == 1 && c == 107
        let power += 5
        let state = 0
        let x += 1
      else
        let power -= 1
      endif
      if power < 0 | let power = 0 | endif
      if power > 50 | let power = 50 | endif
      if x > 22
	    echomsg "ファール！"
        let state = 4
      endif
      if state == 0
        call setline(16, repeat(" ", x) . "     !!ﾊｧﾊｧ")
        call setline(17, repeat(" ", x) . "<(;´Д`)v ")
      elseif state == 1
        call setline(16, repeat(" ", x) . "     ﾊｧﾊｧ!!")
        call setline(17, repeat(" ", x) . "L(|´д`)V ")
      endif
      call setline(19, repeat("=", power) . ' ' . power)
    endif
    sleep 50ms
    redraw
  endwhile
  call s:cursor_on(1)
  bdelete
endfunction

command! -nargs=0 Habatobi call s:start()
