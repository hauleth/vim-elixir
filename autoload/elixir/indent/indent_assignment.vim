function! elixir#indent#indent_assignment#(ind, data)
  if a:data.last_line =~ elixir#indent#().ending_with_assignment
    let b:old_ind.pipeline = indent(a:data.last_line_ref) " FIXME: side effect
    return a:ind + &sw
  else
    return a:ind
  end
endfunction
