@echo off
if not exist "dist/" (
    mkdir dist
)
lua bundle.lua bundle.lua -o dist/bundle.lua