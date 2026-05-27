@echo off
cd /d "%~dp0.."
git submodule update --init --recursive
git submodule foreach --recursive "git checkout HEAD -- . || true"
