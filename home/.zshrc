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


# prompts: https://github.com/ohmyzsh/ohmyzsh/blob/c1b798aff39942b2f23a0a5f2ef206ebc8ce4970/themes/agnoster.zsh-theme
setopt -o promptsubst
PL_CUR_BG="NONE"
PL_SEP=$'\ue0b0'

prompt_segment() {
	if [ "${PL_CUR_BG}" != "NONE" -a "${1}" != "${PL_CUR_BG}" ]; then
		echo -n " %{%K{${1}}%F{$PL_CUR_BG}%}$PL_SEP%{%F{${2}}%} "
	else
		echo -n "%{%K{${1}}%}%{%}%F{${2}} "
	fi
	PL_CUR_BG="${1}"
	echo -n "${3}"
}

prompt_end() {
	if [ -n ${PL_CUR_BG} ]; then
		echo -n " %{%k%F{${PL_CUR_BG}}%}${PL_SEP}"
	else
		echo -n "%{%k%}"
	fi
	echo -n "%{%f%}"
	PL_CUR_BG=
}

build_prompt() {
	prompt_segment "${COL_DWM_CYAN}" "${COL_DWM_GRAY4}" ":"
	prompt_segment "magenta" "green" aoeu
	if [ "${LAST_RC}" -ne 0 ]; then
		prompt_segment "red" "black" "${LAST_RC}"
	fi
	if [ -z "${TMUX}" ]; then
		prompt_segment "yellow" "black" "!tmux"
	fi
	prompt_segment "${COL_DWM_CYAN}" "${COL_DWM_GRAY4}" ";"
	prompt_end
}
PS1="%{%f%k%}\$(build_prompt) "


function precmd() {

	# set LAST_RC only if the last execution failed; ignore ^C or empty executions
	rc=${?}
	if [ -z "${PRE_EXECD}" ]; then
		LAST_RC=0
	else
		LAST_RC="${rc}"
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


# git PS1
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	GIT_PS1_SHOWDIRTYSTATE="true"
	GIT_PS1_SHOWSTASHSTATE="true"
	GIT_PS1_SHOWUPSTREAM="auto"
	. /usr/share/git/completion/git-prompt.sh
else
	function __git_ps1() { : }
fi


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
