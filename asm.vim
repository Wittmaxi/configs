function! FoldAnalysis( line )
    if stridx(a:line, 'PROC') != -1
        " A level 1 fold starts here; cp :help fold-expr
        return '>1'
    elseif stridx(a:line, 'MACRO') != -1
        " A level 1 fold starts here; cp :help fold-expr
        return '>1'
    elseif stridx(a:line, 'SEGMENT') != -1
        return '>1'
    elseif stridx(a:line, ';- ') != -1
        return '>2'
    elseif stridx(a:line, ';-- ') != -1
        return '>3'
    elseif stridx(a:line, ';--- ') != -1
        return '>4'
   elseif stridx(a:line, 'ENDP') != -1
        " A level 1 fold ends here
        return '<1'
   elseif stridx(a:line, 'ENDM') != -1
        " A level 1 fold ends here
        return '<1'
   elseif stridx(a:line, 'ENDS') != -1
        " A level 1 fold ends here
        return '<1'
    else
        " Use fold level from previous line
        return '='
    endif
endfunction
setlocal foldmethod=expr foldexpr=FoldAnalysis(getline(v:lnum))

set foldtext=FoldText()

  function! FoldText()
    let l:lpadding = &fdc
    redir => l:signs
      execute 'silent sign place buffer='.bufnr('%')
    redir End
    let l:lpadding += l:signs =~ 'id=' ? 2 : 0

    if exists("+relativenumber")
      if (&number)
        let l:lpadding += max([&numberwidth, strlen(line('$'))]) + 1
      elseif (&relativenumber)
        let l:lpadding += max([&numberwidth, strlen(v:foldstart - line('w0')), strlen(line('w$') - v:foldstart), strlen(v:foldstart)]) + 1
      endif
    else
      if (&number)
        let l:lpadding += max([&numberwidth, strlen(line('$'))]) + 1
      endif
    endif

    " expand tabs
    let l:start = substitute(getline(v:foldstart), '\t', repeat(' ', &tabstop), 'g')

    let l:info = ' (' . (v:foldend - v:foldstart) . ')'

    let l:text = l:start

    return l:text . l:info
endfunction

" put semicolon at 40
nnoremap ; 050lr;
