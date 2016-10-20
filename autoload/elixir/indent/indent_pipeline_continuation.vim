function! elixir#indent#indent_pipeline_continuation#(ind, data)
  if a:data.last_line =~ elixir#indent#().starts_with_pipeline
        \ && a:data.current_line =~ elixir#indent#().starts_with_pipeline
    return indent(a:data.last_line_ref)
  else
    return a:ind
  end
endfunction
