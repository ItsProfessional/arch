# zsh on arch will source /etc/profile and thus the scripts in /etc/profile.d for each login shell, some of which will append duplicates, hence we need to invoke this typeset to remove any dupes
typeset -U path

# ensure that these are at the very end of the path, to prevent clobbering of system utils e.g. xpath, nvm
[[ -d ~/src/robbieg.bin ]] && path=("$path[@]" ~/src/robbieg.bin)
[[ -d ~/src/atlassian-scripts ]] && path=("$path[@]" ~/src/atlassian-scripts/bin)

# shell agnostic function returns true if ${1} is a valid executable, function etc.
function haz() {
	return $(type "${1}" > /dev/null 2>&1)
}

# execute tmux if it isn't running; it will replace this process with a new login shell
if [ -z "${TMUX}" ] && haz tmux && [ -f "${HOME}/.tmux.conf" ] && [ -z "${VSCODE_CLI}" ]; then
	exec tmux
fi

# moar history
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# vim CLI mode
bindkey -v

# boot the zsh completion system 
autoload -Uz compinit
compinit

# bindings for insert mode
bindkey "^J" history-beginning-search-forward
bindkey "^K" history-beginning-search-backward

# aliases
local os=$(uname)
if [ "${os}" = "Linux" ]; then
	alias ls="ls --color"
elif [ "${os}" = "Darwin" -o "${os}" = "FreeBSD" ]; then
	alias ls="ls -G"
else
	alias ls="ls -F"
fi
if [ "${os}" = "Linux" -o "${os}" = "Darwin" ]; then
	alias diff="diff --color"
fi
alias ll="ls -lh"
alias lla="ll -a"
alias grep="grep --color"
alias rgrep="find . -type f -print0 | xargs -0 grep --color"
if [ -d ~/src/git-scripts ]; then
	alias git-merge-poms='git mergetool --tool=versions -y'
fi
unset os

# select host prompt colour from: black, red, green, yellow, blue, magenta, cyan, white
local promptColour
case "$(hostname)" in
emperor*)
	promptColour="green"
	;;
tinygod*)
	promptColour="blue"
	;;
lord*)
	promptColour="magenta"
	;;
* )
	promptColour="yellow"
	;;
esac

# root prompt is always red
if [ "${USER}" = "root" ]; then
	promptColour="red"
fi

# prompt:
#   bg red background nonzero return code and newline
#   bg host background coloured ":; " in black text
PS1="%(?..%F{black}%K{red}%?%k%f"$'\n'")%F{black}%K{${promptColour}}:;%k%f "
PS2="%K{${promptColour}}:; %_%k "

# title pwd and __git_ps1 (if present)
#   "\e]0;" ESC xterm (title) code
#   "\a"	BEL
[[ -f /usr/share/git/completion/git-prompt.sh ]] && . /usr/share/git/completion/git-prompt.sh
if haz __git_ps1; then

	# show extra flags
	export GIT_PS1_SHOWDIRTYSTATE=true
	export GIT_PS1_SHOWSTASHSTATE=true
	precmd() {
		printf "\e]0;%s%s\a" "${PWD}" "$(__git_ps1)"
	}
else
	precmd() {
		printf "\e]0;%s\a" "${PWD}"
	}
fi
unset promptColour

# user mount helpers
if haz udisksctl; then
	mnt() {
		if [ ${#} -ne 1 ]; then
			echo "Usage: ${FUNCNAME} <block device>" >&2
			return 1
		fi
		udisksctl mount -b ${1} && cd "$(findmnt -n -o TARGET ${1})"
	}
	umnt() {
		if [ ${#} -ne 1 ]; then
			echo "Usage: ${FUNCNAME} <block device>" >&2
			return 1
		fi
		udisksctl unmount -b ${1}
	}
fi

# music management utilities
if [ -d /net/lord/music ]; then
	alias music-home-to-lord="rsync -a -v --omit-dir-times --delete-after \${HOME}/Music/ /net/lord/music/"
fi
if haz simple-mtpfs; then
	mntmtp() {
		mkdir ${XDG_RUNTIME_DIR}/mtp > /dev/null 2>&1
		simple-mtpfs ${XDG_RUNTIME_DIR}/mtp
		cd ${XDG_RUNTIME_DIR}/mtp
		pwd
	}
	umntmtp() {
		fusermount -u ${XDG_RUNTIME_DIR}/mtp
		rmdir ${XDG_RUNTIME_DIR}/mtp
	}
	alias music-lord-to-android="rsync -a -v --omit-dir-times --update --delete-after /net/lord/music/ \${XDG_RUNTIME_DIR}/mtp/Music/"
fi

# use the keychain wrapper to start ssh-agent if needed
if haz keychain && [ -f ~/.ssh/id_rsa ]; then
	eval $(keychain --eval --quiet --agents ssh ~/.ssh/id_rsa)
fi
