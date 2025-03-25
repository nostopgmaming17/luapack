# Lua Packer
a lua bundler and minifier fully coded in lua
this packer automatically translate require calls to include the files
the require calls cannot be something like require("something.dependacy") instead it has to be require("something/dependacy")

you can use this by copying dist/bundle.lua or downloading/cloning the github and running either minifybundle.bat or `lua bundle.lua bundle.lua`

bundling:
`lua bundle.lua [entrypoint] [?-o output]`

Special thanks to stravant for the minify code https://github.com/stravant/LuaMinify
