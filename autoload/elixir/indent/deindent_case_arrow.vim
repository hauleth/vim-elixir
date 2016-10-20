function! elixir#indent#deindent_case_arrow#(ind, data)
  if get(b:old_ind, 'arrow', 0) > 0
        \ && (a:data.current_line =~ elixir#indent#().arrow
        \ || a:data.current_line =~ elixir#indent#().block_end)
    let ind = b:old_ind.arrow
    let b:old_ind.arrow = 0
    return ind
  else
    return a:ind
  end
endfunction
