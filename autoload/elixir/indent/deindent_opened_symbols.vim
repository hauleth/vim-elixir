function! elixir#indent#deindent_opened_symbols#(ind, data)
  let s:opened_symbol =
        \   a:data.pending_parenthesis
        \ + a:data.pending_square_brackets
        \ + a:data.pending_brackets

  if s:opened_symbol < 0
    let ind = get(b:old_ind, 'symbol', a:ind + (s:opened_symbol * &sw))
    let ind = float2nr(ceil(floor(ind, data)/&sw)*&sw)
    return ind <= 0 ? 0 : ind
  else
    return a:ind
  end
endfunction
