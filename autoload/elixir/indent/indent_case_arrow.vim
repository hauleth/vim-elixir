function! elixir#indent#indent_case_arrow#(ind, data)
  if a:data.last_line =~ elixir#indent#().end_with_arrow && a:data.last_line !~ '\<fn\>'
    let b:old_ind.arrow = a:ind
    return a:ind + &sw
  else
    return a:ind
  end
endfunction
