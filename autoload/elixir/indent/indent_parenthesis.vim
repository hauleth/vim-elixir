function! elixir#indent#indent_parenthesis#(ind, data)
  if a:data.pending_parenthesis > 0
        \ && a:data.last_line !~ '^\s*def'
        \ && a:data.last_line !~ elixir#indent#().end_with_arrow
    let b:old_ind.symbol = a:ind
    return matchend(a:data.last_line, '(')
  else
    return a:ind
  end
endfunction
