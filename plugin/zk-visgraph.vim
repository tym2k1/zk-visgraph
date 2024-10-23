" Title:        zk-visgraph
" Description:  A plugin to provide a note graph for the zk-nvim <https://github.com/zk-org>.
" Last Change:  23 October 2024
" Maintainer:   tym2k1 <https://github.com/tym2k1>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_zkvisgraph")
    finish
endif
let g:loaded_zkvisgraph = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/zk-visgraph/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 ZkShowGraph lua require("zk-visgraph").show_graph()
