# Set a TERM appropriate for tmux, based on the "real terminal" that TMUX propagates.
# Too expensive for precmd.
# Manually invoke when attaching to an existing session from a different terminal type.
function updatetmuxterm() {
	if [ -n "${TMUX}" ]; then
		case $(tmux show-environment TERM 2>/dev/null) in
			*256color|*alacritty)
				TERM="tmux-256color"
				;;
			*)
				TERM="tmux"
				;;
		esac
	fi
}

# replace this shell with tmux, attaching to detached if present
function tm() {
	if [ $(whence tmux) -a -z "${TMUX}" ]; then
		DETACHED="$( tmux ls 2>/dev/null | grep -vm1 attached | cut -d: -f1 )"
		if [ -z "${DETACHED}" ]; then
			exec tmux
		else
			exec tmux attach -t "${DETACHED}"
		fi
	fi
}


# dwm colours
C_D_GRAY1="#222222"
C_D_GRAY2="#444444"
C_D_GRAY3="#bbbbbb"
C_D_GRAY4="#eeeeee"
C_D_CYAN="#005577"

# zsh colours
C_Z_O="%k%f"
C_Z_E="%F{black}%K{red}"
C_Z_W="%F{black}%K{yellow}"
C_Z_N="%F{${C_D_GRAY4}}%K{${C_D_CYAN}}"

# tmux colours
export C_T_N="fg=${C_D_GRAY4},bg=${C_D_CYAN}"


# maybe exec tmux
if [ ! -f "${HOME}/notmux" ] ; then
	tm
fi
if [ -n "${TMUX}" ]; then
	updatetmuxterm
fi

# remove duplicates coming from arch's /etc/profile.d
typeset -U path


# zsh completion
autoload -Uz compinit
compinit
eval $(dircolors)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select


# moar history
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000


# vim zle mode with proper deletes
bindkey -v
bindkey -M viins "${terminfo[kdch1]}" delete-char
bindkey -M vicmd "${terminfo[kdch1]}" delete-char

# shift tab
bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete

# search up to cursor
bindkey -M viins "^J" history-beginning-search-forward
bindkey -M viins "^K" history-beginning-search-backward

# incremental search which uses a limited set of regular bindings, overridden by the (empty) isearch map
bindkey -M viins "^F" history-incremental-search-forward
bindkey -M viins "^B" history-incremental-search-backward

# not using any esc, something sequences so drop the timeout from 40 for better editing responsiveness
KEYTIMEOUT=1


# vim cursor style; using the same VTE values as vim terminus plugin for these nonstandard extensions
# normal: block: 2
# replace: underscore: 4 (not yet in ZLE...)
# insert: beam: 6
function updatecursor() {
	case ${KEYMAP} in
		(vicmd)
			printf "\033[2 q"
			;;
		(*)
			printf "\033[6 q"
			;;
	esac
}
zle -N zle-line-init updatecursor
zle -N zle-keymap-select updatecursor
function resetcursor() {
	printf "\033[2 q"
}
zle -N zle-line-finish resetcursor


# git PS1
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	GIT_PS1_SHOWDIRTYSTATE="true"
	GIT_PS1_SHOWSTASHSTATE="true"
	GIT_PS1_SHOWUPSTREAM="auto"
	. /usr/share/git/completion/git-prompt.sh
else
	function __git_ps1() { : }
fi

# prompts
setopt -o promptsubst
PR_STA="${C_Z_N}:${C_Z_O}"
PR_ERR= # dynamically set by precmd
if [ -z "${TMUX}" ]; then
	PR_WAR="${C_Z_W} -tm ${C_Z_O}"
fi
PR_END="${C_Z_N};${C_Z_O}"
PS1="${PR_STA}${PR_WAR}\${PR_ERR}${PR_END} "
PS2="${C_Z_N}%_>${C_Z_O} "
PS3="${C_Z_N}?#${PS3}${C_Z_O} "
PS4="${C_Z_N}+%N:%i>${C_Z_O} "
unset PR_STA PR_WAR PR_END

function precmd() {
	# set PR_ERR only if the last execution failed; ignore ^C or empty executions
	rc=${?}
	if [ -z "${PRE_EXECD}" -o "${rc}" -eq 0 ]; then
		PR_ERR=
	else
		#PR_ERR="${C_Z_E} ${rc} ${C_Z_O}"
		PR_ERR="${rc}"
	fi
	PRE_EXECD=

	# terminal title
	if [ -n "${ALACRITTY_THEME}" ]; then
		print -Pn "${terminfo[tsl]}%~$(__git_ps1) {${ALACRITTY_THEME}}${terminfo[fsl]}"
	else
		print -Pn "${terminfo[tsl]}%~$(__git_ps1)${terminfo[fsl]}"
	fi
}
function preexec() {
	PRE_EXECD="oui"
}

# use the keychain wrapper to start ssh-agent if needed
if [ $(whence keychain) -a -f ~/.ssh/id_rsa ]; then
	eval $(keychain --eval --quiet --agents ssh ~/.ssh/id_rsa)
fi


# general aliases
alias ls="ls --color=auto"
alias ll="ls -lh"
alias lla="ll -a"
alias grep="grep --color=auto"
alias grepc="grep --color=always"
alias diff="diff --color=auto"
alias diffc="diff --color=always"
alias rgrep="find . -type f -print0 | xargs -0 grep --color=auto"
alias rgrepc="find . -type f -print0 | xargs -0 grep --color=always"
alias diffp="diff -Naur"
alias pt='pstree -TapU -C age'
alias ptw='watch -t -n 0.5 -c pstree -TapU -C age'
alias agh='ag --hidden'
alias todo='todo.sh'
alias vidone='vi ~/.todo/todotxt/done.txt'
alias vitodo='vi ~/.todo/todotxt/todo.txt'

# music management aliases
alias music-home-to-lord="rsync -a -v --omit-dir-times --delete-after \${HOME}/music/ /net/lord/music/"
alias music.arch-home-to-lord="rsync -a -v --omit-dir-times --delete-after \${HOME}/music.arch/ /net/lord/music.arch/"
alias music-lord-to-home="rsync -a -v --omit-dir-times --delete-after /net/lord/music/ \${HOME}/music/"
alias music.arch-lord-to-home="rsync -a -v --omit-dir-times --delete-after /net/lord/music.arch/ \${HOME}/music.arch/"
alias music-home-to-android="adb-sync --delete \${HOME}/music/ /sdcard/Music"
alias music-lord-to-android="adb-sync --delete /net/lord/music/ /sdcard/Music"
alias music-android-to-home="adb-sync --delete --reverse /sdcard/Music/ \${HOME}/music"

colours

#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color schema, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

# Special Powerline characters

() {
	local LC_ALL="" LC_CTYPE="en_US.UTF-8"
	# NOTE: This segment separator character is correct.  In 2012, Powerline changed
	# the code points they use for their special characters. This is the new code point.
	# If this is not working for you, you probably have an old version of the
	# Powerline-patched fonts installed. Download and install the new version.
	# Do not submit PRs to change this unless you have reviewed the Powerline code point
	# history and have new information.
	# This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
	# what font the user is viewing this source code in. Do not replace the
	# escape sequence with a single literal character.
	# Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
	SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
	local bg fg
	[[ -n $1 ]] && bg="%K{$1}" || bg="%k"
	[[ -n $2 ]] && fg="%F{$2}" || fg="%f"
	if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
		echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
	else
		echo -n "%{$bg%}%{$fg%} "
	fi
	CURRENT_BG=$1
	[[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
	if [[ -n $CURRENT_BG ]]; then
		echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
	else
		echo -n "%{%k%}"
	fi
	echo -n "%{%f%}"
	CURRENT_BG=''
}

## Main prompt
build_prompt() {
	prompt_segment "${C_D_CYAN}" "${C_D_GRAY4}" ":"

	if [ -n "${PR_ERR}" ]; then
		prompt_segment red black "${PR_ERR}"
	fi

	if [ -z "${TMUX}" ]; then
		prompt_segment yellow black "!tmux"
	fi

	prompt_segment "${C_D_CYAN}" "${C_D_GRAY4}" ";"

	prompt_end
}
PS1='%{%f%k%}$(build_prompt) '
