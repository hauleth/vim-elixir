function! elixir#indent#deindent_keywords#(ind, data)
  if a:data.current_line =~ elixir#indent#().deindent_keywords
    let bslnum = searchpair(
          \ elixir#indent#().pair_start,
          \ elixir#indent#().pair_middle,
          \ elixir#indent#().pair_end,
          \ 'nbW',
          \ elixir#indent#().block_skip
          \ )

    return indent(bslnum)
  else
    return a:ind
  end
endfunction
