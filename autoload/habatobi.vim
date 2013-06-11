scriptencoding utf-8

let s:cursor_off = 0
let s:cursor_on = 1
let s:cursor = {}
function! s:cursor_toggle(f)
  if empty(s:cursor)
    for name in ['Cursor']
      redir => colors
      exe "silent!" "hi" name
      redir END
      let s:cursor[name] = substitute(matchstr(colors, 'xxx\zs.*'), "\n", ' ', 'g')
    endfor
  endif
  if a:f
    for name in keys(s:cursor)
      exe "hi" name s:cursor[name]
    endfor
  else
    for name in keys(s:cursor)
      exe "hi ".name." term=NONE ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE"
    endfor
  endif
endfunction

let s:state_left = 0
let s:state_right = 1
let s:state_jump = 2
let s:state_finish = 3
let s:state_fault = 4
let s:max_power = 50

function! habatobi#start()
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
  let state = s:state_left
  let x = 0
  call s:cursor_toggle(s:cursor_off)
  while 1
    let c = getchar(0)
    if c == 27 || c == 113 " esc or q
      " quit game loop
      break
    endif
    if state == s:state_finish
      " do nothing
    elseif state == s:state_jump
      " jumping animation
      let dy = 40
      let jx = x * 100
      let jy = 1600
      let wh = winheight(".")
      while dy >= -40
        call setline(jy / 100,   repeat(" ", jx / 100) . "           ")
        call setline(jy / 100+1, repeat(" ", jx / 100) . "           ")
        let jx += power
        let jy -= dy
        let dy -= 1
        call setline(jy / 100,   repeat(" ", jx / 100) . "  ヽｾｲﾔｧ!ノ")
        call setline(jy / 100+1, repeat(" ", jx / 100) . "(; ﾟДﾟ)   ")
        call setline(17, repeat(" ", jx / 100) . " ---     ")
        redraw
        sleep 10ms
      endwhile
      call setline(16, repeat(" ", jx / 100) . "   ヽｹﾞﾌｯノ")
      call setline(17, repeat(" ", jx / 100) . "(;´Д`)   ")
      echomsg "記録: " . printf("%.02fメートル", (str2float(jx)/100 - 23) / 10)
      let state = s:state_finish
    else
      if c == 32 " space key
        let state = s:state_jump
      elseif state == s:state_left && c == 106 " j key
        let power += 5
        let state = s:state_right
        let x += 1
      elseif state == s:state_right && c == 107 " k key
        let power += 5
        let state = s:state_left
        let x += 1
      else
        let power -= 1
      endif
      if power < 0 | let power = 0 | endif
      if power > s:max_power | let power = s:max_power | endif
      if x > 22
        echomsg "ファール！"
        let state = s:state_fault
      endif
      if state == s:state_left
        call setline(16, repeat(" ", x) . "     !!ﾊｧﾊｧ")
        call setline(17, repeat(" ", x) . "<(;´Д`)v ")
      elseif state == s:state_right
        call setline(16, repeat(" ", x) . "     ﾊｧﾊｧ!!")
        call setline(17, repeat(" ", x) . "L(|´д`)V ")
      endif
      call setline(19, repeat("=", power) . ' ' . power)
    endif
    sleep 50ms
    redraw
  endwhile
  call s:cursor_toggle(s:cursor_on)
  bdelete
endfunction
