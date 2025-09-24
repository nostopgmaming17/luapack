# Luapack - Lua project bundler for lua & luau
a lua bundler and minifier fully coded in lua
designed for simplicity, lightweight usage and ease of use

a simple straightforward application to bundle many lua files together into one

this packer automatically translate require calls to include the files

you can use this by copying dist/bundle.lua or downloading/cloning the github and running either minifybundle.bat or `lua bundle.lua bundle.lua`

bundling:
`lua bundle.lua [entrypoint] [?-o output] [?-d variable=value -d "variable=value" -d 'variable=value']`
- defines replace the string code with new value
- for example if you had a define Hello=Bob then even when you do print("Hello") it will replace it with bob therefore you might want to add a prefix to it like `%HELLO%` or `_DEF_HELLO` and etc

Special thanks to stravant for the minify code https://github.com/stravant/LuaMinify
