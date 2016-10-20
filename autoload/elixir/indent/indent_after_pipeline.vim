function! elixir#indent#indent_after_pipeline#(ind, data)
  if a:data.last_line =~ elixir#indent#().starts_with_pipeline
    if empty(substitute(a:data.current_line, ' ', '', 'g'))
          \ || a:data.current_line =~ elixir#indent#().starts_with_pipeline
      return indent(a:data.last_line_ref)
    elseif a:data.last_line !~ elixir#indent#().indent_keywords
      let ind = b:old_ind.pipeline
      let b:old_ind.pipeline = 0
      return ind
    end
  end

  return a:ind
endfunction
