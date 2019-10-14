let s:is_windows = has('win32')

function! s:runner_validate() abort
  if !has('nvim')
    throw 'This runner requires Neovim. Use job runner in Vim instead.'
  endif
  if !s:is_windows && !executable('sh')
    throw 'This runner requires sh in Linux/macOS'
  endif
endfunction

function! s:runner_run(commands, input, session) abort dict
  let command = join(a:commands, ' && ')
  let cmd_arg = s:is_windows
        \ ? printf('cmd.exe /c (%s)', command)
        \ : ['sh', '-c', command]
  let options = {
        \ 'session': a:session.continue(),
        \ 'on_stdout': funcref('s:on_stdout'),
        \ 'on_stderr': funcref('s:on_stdout'),
        \ 'on_exit': funcref('s:on_exit'),
        \}
  let self._job = jobstart(cmd_arg, options)
  if !empty(a:input)
    call chansend(self._job, a:input)
    call chanclose(self._job)
  endif
endfunction

function! s:runner_sweep() abort dict
  if !has_key(self, '_job')
    return
  endif
  try
    call jobstop(self._job)
  catch /^Vim\%((\a\+)\)\=:E900/
  endtry
endfunction

function! s:on_stdout(job_id, data, event) abort dict
  let message = join(a:data, "\n")
  call quickrun#session(self.session, 'output', message)
endfunction

function! s:on_exit(job_id, exitval, event) abort dict
  call quickrun#session(self.session, 'finish', a:exitval)
endfunction


function! quickrun#runner#neovim_job#new() abort
  let runner = {
        \ 'config': {
        \   'cwd': v:null,
        \   'pty': v:null,
        \ },
        \ 'validate': funcref('s:runner_validate'),
        \ 'run': funcref('s:runner_run'),
        \ 'sweep': funcref('s:runner_sweep'),
        \}
  return runner
endfunction
