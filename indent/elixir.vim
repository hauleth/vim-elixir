setlocal nosmartindent
setlocal indentexpr=elixir#indent()
setlocal indentkeys+=0),0],0=\|>,=->
setlocal indentkeys+=0=end,0=else,0=match,0=elsif,0=catch,0=after,0=rescue

if exists("b:did_indent") || exists("*elixir#indent")
  finish
end
let b:did_indent = 1

let s:cpo_save = &cpo
set cpo&vim

function! elixir#indent()
  let data = s:build_data(v:lnum)
  let b:old_ind = get(b:, 'old_ind', {})

  if data.last_line_ref == 0
    " At the start of the file use zero indent.
    let b:old_ind = {}
    return 0
  elseif !elixir#util#is_indentable_at(data.current_line_ref, 1)
    " Current syntax is not indentable, keep last line indentation
    return indent(data.last_line_ref)
  else
    let ind = indent(data.last_line_ref)
    let ind = elixir#indent#deindent_case_arrow(ind, data)
    let ind = elixir#indent#indent_parenthesis(ind, data)
    let ind = elixir#indent#indent_square_brackets(ind, data)
    let ind = elixir#indent#indent_brackets(ind, data)
    let ind = elixir#indent#deindent_opened_symbols(ind, data)
    let ind = elixir#indent#indent_pipeline_assignment(ind, data)
    let ind = elixir#indent#indent_pipeline_continuation(ind, data)
    let ind = elixir#indent#indent_after_pipeline(ind, data)
    let ind = elixir#indent#indent_assignment(ind, data)
    let ind = elixir#indent#indent_ending_symbols(ind, data)
    let ind = elixir#indent#indent_keywords(ind, data)
    let ind = elixir#indent#deindent_keywords(ind, data)
    let ind = elixir#indent#deindent_ending_symbols(ind, data)
    let ind = elixir#indent#indent_case_arrow(ind, data)
    return ind
  end
endfunction

function! s:build_data(line)
  let data = {}
  let data.current_line_ref = a:line
  let data.last_line_ref = prevnonblank(data.current_line_ref - 1)
  let data.current_line = getline(data.current_line_ref)
  let data.last_line = getline(data.last_line_ref)

  return data
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
