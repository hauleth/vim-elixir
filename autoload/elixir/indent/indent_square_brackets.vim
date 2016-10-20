function! elixir#indent#indent_square_brackets#(ind, data)
  if a:data.pending_square_brackets > 0
    if a:data.last_line =~ '[\s*$'
      return a:ind + &sw
    else
      " if start symbol is followed by a character, indent based on the
      " whitespace after the symbol, otherwise use the default shiftwidth
      " Avoid negative indentation index
      return matchend(a:data.last_line, '[\s*')
    end
  else
    return a:ind
  end
endfunction
