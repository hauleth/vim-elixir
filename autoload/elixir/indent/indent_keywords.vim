function! elixir#indent#indent_keywords#(ind, data)
  if a:data.last_line =~ elixir#indent#().indent_keywords
    return a:ind + &sw
  else
    return a:ind
  end
endfunction
