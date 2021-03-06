" Vawa Plugin for VIM > 7.3 version 1.00
" Maintainer:	Sandeep.c.r<sandeepcr2@gmail.com>
"
" Copyright (c) 2014 Sandeep.C.R <sandeepcr2@gmail.com>
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

function! s:vawa()
    if (exists("w:vawa_match_id") && w:vawa_match_id !=0)
        try
            call matchdelete(w:vawa_match_id)
        catch
        endt
        let w:vawa_match_id = 0 
    endif
    let s:temp = getpos('.')
    let s:current_col = s:temp[2]
    let s:current_line = s:temp[1]
    let s:temp = searchpos('->\|\$\|::','bcnW')
    let s:dollar_line = s:temp[0]
    let s:dollar_col = s:temp[1]

    if(s:dollar_line != s:current_line)
        return
    endif

    let s:temp = getbufline(bufnr('%'),line('.'))
    let s:varend = match(s:temp[0], '[^a-zA-Z0-9_\x7f-\xff]\|$', s:dollar_col + 1)

    if(s:varend == -1 || s:varend < s:current_col - 1)
        return
    endif

    let s:current_char = s:temp[0][s:current_col-1]

    if(exists("g:vawahl"))
        exe "highlight VarHl  " . g:vawahl
    else
        highlight VarHl  ctermbg=black ctermfg=red guifg=#ff0000 guibg=#000000 ctermfg=LightRed gui=bold
    endif

    let s:str = strpart(s:temp[0], s:dollar_col,(s:varend - s:dollar_col))
    let s:prefix = ''
    "if(exists("g:vawanohlcurrent") && (g:vawanohlcurrent == 1))
    "    let s:lineab = s:current_line - 1
    "    let s:linebe = s:current_line + 1
    "    let s:colbf  = s:dollar_col + 1
    "    let s:prefix = '\(\%>'.s:lineab.'l.\%<'.s:linebe.'l.\%>'.s:colbf.'c\)\@!'
    "endif
    if (strlen(s:str) < 2)
        return
    endif
    try
        if(strpart(s:str,0,1) == '>' || strpart(s:str,0,1) == ':')
            let s:str = strpart(s:str ,1)
            "let w:vawa_match_id = matchadd('VarHl', s:prefix.'[>:]\@<='.s:str.'\n\{-\}\(\([^a-zA-Z0-9_\x7f-\xff]\)\|$\)\@=')
            let w:vawa_match_id = matchadd('VarHl', s:prefix.'[>:]\@<=\<'.s:str.'\>')
        else
            "let w:vawa_match_id = matchadd('VarHl', s:prefix.s:str.'\n\{-\}\(\([^a-zA-Z0-9_\x7f-\xff]\)\|$\)\@=')
            let w:vawa_match_id = matchadd('VarHl', s:prefix.'\$\@<=\<'.s:str.'\>')
        endif
    catch
    endt
endfunction
if(!exists("g:vawanoauto") || (g:vawanoauto == 1))
    augroup HighlightVar
            autocmd!
            au CursorMoved *.php call <sid>vawa()
            au CursorMovedi *.php call <sid>vawa()
            au CursorMoved *.phtml call <sid>vawa()
            au CursorMovedi *.phtml call <sid>vawa()
    augroup END
endif

command! Vawa :call <sid>vawa()

