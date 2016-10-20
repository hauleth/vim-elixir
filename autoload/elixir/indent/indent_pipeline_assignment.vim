function! elixir#indent#indent_pipeline_assignment#(ind, data)
  if a:data.current_line =~ elixir#indent#().starts_with_pipeline
        \ && a:data.last_line =~ '^[^=]\+=.\+$'
    let b:old_ind.pipeline = indent(a:data.last_line_ref)
    " if line starts with pipeline
    " and last line is an attribution
    " indents pipeline in same level as attribution
    return match(a:data.last_line, '=\s*\zs[^ ]')
  else
    return a:ind
  end
endfunction
