function! elixir#indent#indent_ending_symbols#(ind, data)
  if a:data.last_line =~ '^\s*\('.elixir#indent#().ending_symbols.'\)\s*$'
    return a:ind + &sw
  else
    return a:ind
  end
endfunction
