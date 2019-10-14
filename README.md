# vim-quickrun-neovim-job

Non official job runner of [vim-quickrun][] for Neovim.

[vim-quickrun]: https://github.com/thinca/vim-quickrun

## Usage

```vim
let g:quickrun_config = {'_': {}}

if has('nvim')
  " Use 'neovim_job' in Neovim
  let g:quickrun_config._.runner = 'neovim_job'
elseif exists('*ch_close_in')
  " Use 'job' in Vim which support job feature
  let g:quickrun_config._.runner = 'job'
endif
```
