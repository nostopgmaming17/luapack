@echo off
if not exist "out/" (
    mkdir out
)
lua bundle.lua bundle.lua -o out/bundle.lua -d BUNDLED=true