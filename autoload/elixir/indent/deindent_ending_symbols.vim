function! elixir#indent#deindent_ending_symbols#(ind, data)
  if a:data.current_line =~ '^\s*\('.elixir#indent#().ending_symbols.'\)'
    return a:ind - &sw
  else
    return a:ind
  end
endfunction
