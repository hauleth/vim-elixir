let s:constants = {}
let s:NO_COLON_BEFORE = ':\@<!'
let s:NO_COLON_AFTER = ':\@!'
let s:ENDING_SYMBOLS = '\]\|}\|)'
let s:STARTING_SYMBOLS = '\[\|{\|('
let s:ARROW = '->'
let s:END_WITH_ARROW = s:ARROW.'$'
let s:SKIP_SYNTAX = '\%(Comment\|String\)$'
let s:BLOCK_SKIP = "synIDattr(synID(line('.'),col('.'),1),'name') =~? '".s:SKIP_SYNTAX."'"
let s:FN = '\<fn\>'
let s:MULTILINE_FN = s:FN.'\%(.*end\)\@!'
let s:BLOCK_START = '\%(\<do\>\|'.s:FN.'\)\>'
let s:MULTILINE_BLOCK = '\%(\<do\>'.s:NO_COLON_AFTER.'\|'.s:MULTILINE_FN.'\)'
let s:BLOCK_MIDDLE = '\<\%(else\|match\|elsif\|catch\|after\|rescue\)\>'
let s:BLOCK_END = 'end'
let s:STARTS_WITH_PIPELINE = '^\s*|>.*$'
let s:ENDING_WITH_ASSIGNMENT = '=\s*$'

let s:INDENT_KEYWORDS = s:NO_COLON_BEFORE.'\%('.s:MULTILINE_BLOCK.'\|'.s:BLOCK_MIDDLE.'\)'
let s:DEINDENT_KEYWORDS = '^\s*\<\%('.s:BLOCK_END.'\|'.s:BLOCK_MIDDLE.'\)\>'

let s:PAIR_START = '\<\%('.s:NO_COLON_BEFORE.s:BLOCK_START.'\)\>'.s:NO_COLON_AFTER
let s:PAIR_MIDDLE = '^\s*\%('.s:BLOCK_MIDDLE.'\)\>'.s:NO_COLON_AFTER.'\zs'
let s:PAIR_END = '\<\%('.s:NO_COLON_BEFORE.s:BLOCK_END.'\)\>\zs'

function! s:pending_parenthesis(data)
  if a:data.last_line !~ s:ARROW
    return elixir#util#count_indentable_symbol_diff(a:data, '(', '\%(end\s*\)\@<!)')
  end
endfunction

function! s:pending_square_brackets(data)
  if a:data.last_line !~ s:ARROW
    return elixir#util#count_indentable_symbol_diff(a:data, '[', ']')
  end
endfunction

function! s:pending_brackets(data)
  if a:data.last_line !~ s:ARROW
    return elixir#util#count_indentable_symbol_diff(a:data, '{', '}')
  end
endfunction

function! elixir#indent#deindent_case_arrow(ind, data)
  if get(b:old_ind, 'arrow', 0) > 0
        \ && (a:data.current_line =~ s:ARROW
        \ || a:data.current_line =~ s:BLOCK_END)
    let ind = b:old_ind.arrow
    let b:old_ind.arrow = 0
    return ind
  else
    return a:ind
  end
endfunction

function! elixir#indent#deindent_ending_symbols(ind, data)
  if a:data.current_line =~ '^\s*\('.s:ENDING_SYMBOLS.'\)'
    return a:ind - &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#deindent_keywords(ind, data)
  if a:data.current_line =~ s:DEINDENT_KEYWORDS
    let bslnum = searchpair(
          \ s:PAIR_START,
          \ s:PAIR_MIDDLE,
          \ s:PAIR_END,
          \ 'nbW',
          \ s:BLOCK_SKIP
          \ )

    return indent(bslnum)
  else
    return a:ind
  end
endfunction

function! elixir#indent#deindent_opened_symbols(ind, data)
  let s:opened_symbol =
        \   s:pending_parenthesis(a:data)
        \ + s:pending_square_brackets(a:data)
        \ + s:pending_brackets(a:data)

  if s:opened_symbol < 0
    let ind = get(b:old_ind, 'symbol', a:ind + (s:opened_symbol * &sw))
    let ind = float2nr(ceil(floor(ind, data)/&sw)*&sw)
    return ind <= 0 ? 0 : ind
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_after_pipeline(ind, data)
  if a:data.last_line =~ s:STARTS_WITH_PIPELINE
    if empty(substitute(a:data.current_line, ' ', '', 'g'))
          \ || a:data.current_line =~ s:STARTS_WITH_PIPELINE
      return indent(a:data.last_line_ref)
    elseif a:data.last_line !~ s:INDENT_KEYWORDS
      let ind = b:old_ind.pipeline
      let b:old_ind.pipeline = 0
      return ind
    end
  end

  return a:ind
endfunction

function! elixir#indent#indent_assignment(ind, data)
  if a:data.last_line =~ s:ENDING_WITH_ASSIGNMENT
    let b:old_ind.pipeline = indent(a:data.last_line_ref) " FIXME: side effect
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_brackets(ind, data)
  if s:pending_brackets(a:data) > 0
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_case_arrow(ind, data)
  if a:data.last_line =~ s:END_WITH_ARROW && a:data.last_line !~ '\<fn\>'
    let b:old_ind.arrow = a:ind
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_ending_symbols(ind, data)
  if a:data.last_line =~ '^\s*\('.s:ENDING_SYMBOLS.'\)\s*$'
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_keywords(ind, data)
  if a:data.last_line =~ s:INDENT_KEYWORDS
    return a:ind + &sw
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_parenthesis(ind, data)
  if s:pending_parenthesis(a:data) > 0
        \ && a:data.last_line !~ '^\s*def'
        \ && a:data.last_line !~ s:END_WITH_ARROW
    let b:old_ind.symbol = a:ind
    return matchend(a:data.last_line, '(')
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_pipeline_assignment(ind, data)
  if a:data.current_line =~ s:STARTS_WITH_PIPELINE
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
  if a:data.last_line =~ s:STARTS_WITH_PIPELINE
        \ && a:data.current_line =~ s:STARTS_WITH_PIPELINE
    return indent(a:data.last_line_ref)
  else
    return a:ind
  end
endfunction

function! elixir#indent#indent_square_brackets(ind, data)
  if s:pending_square_brackets(a:data) > 0
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
        \ && (a:data.current_line =~ s:ARROW
        \ || a:data.current_line =~ s:BLOCK_END)
    let ind = b:old_ind.arrow
    let b:old_ind.arrow = 0
    return ind
  else
    return a:ind
  end
endfunction
