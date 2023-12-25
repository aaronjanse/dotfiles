#!/usr/bin/env bash

if [ -z "$HISTFILE"  ]; then
	echo -n '%{%F{red}%}' # red
	echo -n "tmp "
	echo -n '%{%f%}'
fi

echo -n '%{%F{yellow}%}' # yellow
dirs | sed 's/\/\(.\)[^\/]*/\/\1/g' | sed s'/.$//' | xargs echo -n ; echo -n $(basename "`pwd`")
echo -n '%{%f%}'

echo -n " "

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$branch" ]; then
	echo -n '%{%F{magenta}%}'
	echo -n "$branch "
	echo -n '%{%f%}'
fi

NIXSHELL=$(echo $PATH | tr ':' '\n' | grep '/nix/store' | sed 's#^/nix/store/[a-z0-9]\+-##' | sed 's#-[^-]\+$##' | xargs)

if [ "$NIXSHELL"  ]; then
	echo -n '%{%F{cyan}%}' # cyan
	echo -n "$NIXSHELL "
	echo -n '%{%f%}'
fi

if [ `whoami` = "root" ]; then
	echo -n "#"
else
	echo -n "λ"
fi

echo -n " "
