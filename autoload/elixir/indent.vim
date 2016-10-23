function! elixir#indent#()
  if !exists('s:constants')
    let s:constants = {}
    let s:constants.no_colon_before = ':\@<!'
    let s:constants.no_colon_after = ':\@!'
    let s:constants.ending_symbols = '\]\|}\|)'
    let s:constants.starting_symbols = '\[\|{\|('
    let s:constants.arrow = '->'
    let s:constants.end_with_arrow = s:constants.arrow.'$'
    let s:constants.skip_syntax = '\%(Comment\|String\)$'
    let s:constants.block_skip = "synIDattr(synID(line('.'),col('.'),1),'name') =~? '".s:constants.skip_syntax."'"
    let s:constants.fn = '\<fn\>'
    let s:constants.multiline_fn = s:constants.fn.'\%(.*end\)\@!'
    let s:constants.block_start = '\%(\<do\>\|'.s:constants.fn.'\)\>'
    let s:constants.multiline_block = '\%(\<do\>'.s:constants.no_colon_after.'\|'.s:constants.multiline_fn.'\)'
    let s:constants.block_middle = '\<\%(else\|match\|elsif\|catch\|after\|rescue\)\>'
    let s:constants.block_end = 'end'
    let s:constants.starts_with_pipeline = '^\s*|>.*$'
    let s:constants.ending_with_assignment = '=\s*$'

    let s:constants.indent_keywords = s:constants.no_colon_before.'\%('.s:constants.multiline_block.'\|'.s:constants.block_middle.'\)'
    let s:constants.deindent_keywords = '^\s*\<\%('.s:constants.block_end.'\|'.s:constants.block_middle.'\)\>'

    let s:constants.pair_start = '\<\%('.s:constants.no_colon_before.s:constants.block_start.'\)\>'.s:constants.no_colon_after
    let s:constants.pair_middle = '^\s*\%('.s:constants.block_middle.'\)\>'.s:constants.no_colon_after.'\zs'
    let s:constants.pair_end = '\<\%('.s:constants.no_colon_before.s:constants.block_end.'\)\>\zs'
  end

  return s:constants
endfunction

function! elixir#indent#deindent_case_arrow(ind, data)
  if get(b:old_ind, 'arrow', 0) > 0
        \ && (a:data.current_line =~ elixir#indent#().arrow
        \ || a:data.current_line =~ elixir#indent#().block_end)
    let ind = b:old_ind.arrow
    let b:old_ind.arrow = 0
    return ind
  else
    return a:ind
  end
endfunction

function! elixir#indent#deindent_ending_symbols(ind, data)
  if a:data.current_line =~ '^\s*\('.elixir#indent#().ending_symbols.'\)'
    return a:ind - &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#deindent_keywords(ind, data)
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

function! elixir#indent#deindent_opened_symbols(ind, data)
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

function! elixir#indent#indent_after_pipeline(ind, data)
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

function! elixir#indent#indent_assignment(ind, data)
  if a:data.last_line =~ elixir#indent#().ending_with_assignment
    let b:old_ind.pipeline = indent(a:data.last_line_ref) " FIXME: side effect
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_brackets(ind, data)
  if a:data.pending_brackets > 0
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_case_arrow(ind, data)
  if a:data.last_line =~ elixir#indent#().end_with_arrow && a:data.last_line !~ '\<fn\>'
    let b:old_ind.arrow = a:ind
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_ending_symbols(ind, data)
  if a:data.last_line =~ '^\s*\('.elixir#indent#().ending_symbols.'\)\s*$'
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_keywords(ind, data)
  if a:data.last_line =~ elixir#indent#().indent_keywords
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_parenthesis(ind, data)
  if a:data.pending_parenthesis > 0
        \ && a:data.last_line !~ '^\s*def'
        \ && a:data.last_line !~ elixir#indent#().end_with_arrow
    let b:old_ind.symbol = a:ind
    return matchend(a:data.last_line, '(')
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_pipeline_assignment(ind, data)
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

function! elixir#indent#indent_pipeline_continuation(ind, data)
  if a:data.last_line =~ elixir#indent#().starts_with_pipeline
        \ && a:data.current_line =~ elixir#indent#().starts_with_pipeline
    return indent(a:data.last_line_ref)
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_square_brackets(ind, data)
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

function! elixir#indent#deindent_case_arrow#(ind, data)
  if get(b:old_ind, 'arrow', 0) > 0
        \ && (a:data.current_line =~ elixir#indent#().arrow
        \ || a:data.current_line =~ elixir#indent#().block_end)
    let ind = b:old_ind.arrow
    let b:old_ind.arrow = 0
    return ind
  else
    return a:ind
  end
endfunction
