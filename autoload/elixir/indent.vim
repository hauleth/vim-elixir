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
