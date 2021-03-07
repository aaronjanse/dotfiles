#!/usr/bin/env bash

# if [ -z "$HISTFILE"  ]; then
# 	echo -n '%{%F{red}%}' # red
# 	echo -n "tmp "
# 	echo -n '%{%f%}'
# fi

# echo -n '%{%F{yellow}%}' # yellow
# dirs | sed 's/\/\(.\)[^\/]*/\/\1/g' | sed s'/.$//' | xargs echo -n ; echo -n $(basename "`pwd`")
# echo -n '%{%f%}'

# echo -n " "

# branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
# if [ "$branch" ]; then
# 	echo -n '%{%F{magenta}%}'
# 	echo -n "$branch "
# 	echo -n '%{%f%}'
# fi

# NIXSHELL=$(echo $PATH | tr ':' '\n' | grep '/nix/store' | sed 's#^/nix/store/[a-z0-9]\+-##' | sed 's#-[^-]\+$##' | xargs)

# if [ "$NIXSHELL" ]; then
# 	echo -n '%{%F{cyan}%}' # cyan
# 	#echo -n "$NIXSHELL "
# 	echo -n "nix "
# 	echo -n '%{%f%}'
# fi

# if [[ "$USER" == "root" ]]; then
# 	echo -n "#"
# elif [[ "$USER" == "private" ]]; then
# 	echo -n "@"
# else
# 	echo -n "λ"
# fi

# echo -n " "

#!/usr/bin/env bash

# if [ -z "$HISTFILE"  ]; then
# 	echo -n '%{%F{red}%}' # red
# 	echo -n "tmp "
# 	echo -n '%{%f%}'
# fi


if [[ "$PWD" == "$HOME" ]]; then
	echo -n '%F{magenta}janse>%f %{\e[?25h%}'
	# stty sane
else
	echo -n '%F{magenta}' # yellow
	dirs | sed 's/\/\(.\)[^\/]*/\/\1/g' | sed s'/.$//' | xargs echo -n ; echo -n $(basename "`pwd`")

	# echo -n " "

	# echo -n '%{%F{cyan}%}' # cyan
	branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
	if [ "$branch" ]; then
		echo -n " %F{cyan}$branch"
		# echo -n '%{%f%}'
	fi

	NIXSHELL=$(echo $PATH | tr ':' '\n' | grep '/nix/store')

	if [ "$NIXSHELL" ]; then
		echo -n ' %F{cyan}nix%f'
	fi

	echo -n "%F{magenta}"

	if [[ "$USER" == "root" ]]; then
		echo -n "#"
	else
		echo -n ">"
	fi

	echo -n '%f %{\e[?25h%}'
fi
