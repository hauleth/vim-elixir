let s:skip_syntax = '\%(Comment\|String\)$'
let s:block_skip = "synIDattr(synID(line('.'),col('.'),1),'name') =~? '".s:skip_syntax."'"

function! elixir#util#is_indentable_at(line, col)
  " TODO: Remove these 2 lines
  " I don't know why, but for the test on spec/indent/lists_spec.rb:24.
  " Vim is making some mess on parsing the syntax of 'end', it is being
  " recognized as 'elixirString' when should be recognized as 'elixirBlock'.
  call synID(a:line, a:col, 1)
  " This forces vim to sync the syntax.
  syntax sync fromstart

  return synIDattr(synID(a:line, a:col, 1), "name")
        \ !~ s:skip_syntax
endfunction

function! elixir#util#is_indentable_match(line, pattern)
  return elixir#util#is_indentable_at(a:line, match(getline(a:line), a:pattern))
endfunction

function! elixir#util#count_pattern(string, pattern)
  let size = strlen(a:string)
  let index = 0
  let counter = 0

  while index < size
    let index = match(a:string, a:pattern, index)
    if index >= 0
      let index += 1
      let counter +=1
    else
      break
    end
  endwhile

  return counter
endfunction

function! elixir#util#count_indentable_symbol_diff(data, open, close)
  if elixir#util#is_indentable_match(a:data.last_line_ref, a:open)
        \ && elixir#util#is_indentable_match(a:data.last_line_ref, a:close)
    return
          \   elixir#util#count_pattern(a:data.last_line, a:open)
          \ - elixir#util#count_pattern(a:data.last_line, a:close)
  else
    return 0
  end
endfunction
