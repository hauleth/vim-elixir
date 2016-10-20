if exists("b:did_indent")
  finish
end
let b:did_indent = 1

setlocal nosmartindent

setlocal indentexpr=GetElixirIndent()
setlocal indentkeys+=0),0],0=end,0=else,0=match,0=elsif,0=catch,0=after,0=rescue,0=\|>,=->

if exists("*GetElixirIndent")
  finish
end

let s:cpo_save = &cpo
set cpo&vim

function! GetElixirIndent()
  let data = s:build_data()
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
    let ind = elixir#indent#deindent_case_arrow#(ind, data)
    let ind = elixir#indent#indent_parenthesis#(ind, data)
    let ind = elixir#indent#indent_square_brackets#(ind, data)
    let ind = elixir#indent#indent_brackets#(ind, data)
    let ind = elixir#indent#deindent_opened_symbols#(ind, data)
    let ind = elixir#indent#indent_pipeline_assignment#(ind, data)
    let ind = elixir#indent#indent_pipeline_continuation#(ind, data)
    let ind = elixir#indent#indent_after_pipeline#(ind, data)
    let ind = elixir#indent#indent_assignment#(ind, data)
    let ind = elixir#indent#indent_ending_symbols#(ind, data)
    let ind = elixir#indent#indent_keywords#(ind, data)
    let ind = elixir#indent#deindent_keywords#(ind, data)
    let ind = elixir#indent#deindent_ending_symbols#(ind, data)
    let ind = elixir#indent#indent_case_arrow#(ind, data)
    return ind
  end
endfunction

function! s:build_data()
  let data = {}
  let data.current_line_ref = v:lnum
  let data.last_line_ref = prevnonblank(data.current_line_ref - 1)
  let data.current_line = getline(data.current_line_ref)
  let data.last_line = getline(data.last_line_ref)

  if data.last_line !~ elixir#indent#().arrow
    let data.pending_parenthesis = elixir#util#count_indentable_symbol_diff(data, '(', '\%(end\s*\)\@<!)')
    let data.pending_square_brackets = elixir#util#count_indentable_symbol_diff(data, '[', ']')
    let data.pending_brackets = elixir#util#count_indentable_symbol_diff(data, '{', '}')
  else
    let data.pending_parenthesis = 0
    let data.pending_square_brackets = 0
    let data.pending_brackets = 0
  end

  return data
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
