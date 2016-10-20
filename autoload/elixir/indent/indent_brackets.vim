function! elixir#indent#indent_brackets#(ind, data)
  if a:data.pending_brackets > 0
    return a:ind + &sw
  else
    return a:ind
  end
endfunction
