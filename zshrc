fullname=`hostname -f 2>/dev/null || hostname`

# What kind of machine is this?
case `uname` in
	Darwin) machine_type="$machine_type:mac";;
esac

case $fullname in
	*vimes*)
		machine_type="$machine_type:python:home:go"
		;;
	*dreamhost.com) ;&
	*newdream.net)
		machine_type="$machine_type:ndn"
		;;
esac

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="kylemarsh"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true" #oh-my-zsh updates
# DISABLE_AUTO_TITLE="true"
# DISABLE_CORRECTION="true"

base_plugins=(git history screen virtualenv)
ndn_plugins=()
python_plugins=(pip virtualenvwrapper)
mac_plugins=(battery brew)

plugins=($base_plugins)
if [[ $machine_type =~ ':mac' ]]; then
	plugins+=($mac_plugins)
fi
if [[ $machine_type =~ ':ndn' ]]; then
	plugins+=($ndn_plugins)
fi
if [[ $machine_type =~ ':python' ]]; then
	plugins+=($python_plugins)
fi

source $ZSH/oh-my-zsh.sh
fpath=($HOME/lib/zsh/functions $fpath)

## Override things that oh-my-zsh doesn't do right ##
# Turn off the damnable shared history
unsetopt share_history

## Make vi bindings useful (more vim; less vi)
#bindkey -v
## Personalized viins bindings
#bindkey -M viins '^R' history-beginning-search-backward
#bindkey -M viins '^?' backward-delete-char
#bindkey -M viins '^[OH' beginning-of-line
#bindkey -M viins '^[OF' end-of-line
#bindkey -M viins '^[[3~' delete-char
#bindkey -M viins '^[[A' vi-up-line-or-history
#bindkey -M viins '^[[B' vi-down-line-or-history

## Personalized vicmd bindings
#bindkey -M vicmd '^[[3~' delete-char
#bindkey -M vicmd 'k' vi-up-line-or-history
#bindkey -M vicmd 'j' vi-down-line-or-history
#bindkey -M vicmd '/' history-incremental-search-backward
#bindkey -M vicmd '?' history-incremental-search-backward

# Git prompt stuff
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr "%{$fg[green]%}●"
zstyle ':vcs_info:*' unstagedstr "%{$fg[yellow]%}●"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git svn
precmd() {
	if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
		zstyle ':vcs_info:*' formats "%{$reset_color%}(%{$fg[red]%}%b%{$reset_color%}:%c%u%{$reset_color%}) "
	} else {
		zstyle ':vcs_info:*' formats "%{$reset_color%}(%{$fg[red]%}%b%{$reset_color%}:%c%u%{$fg[white]%}●%{$reset_color%}) "
	}
	vcs_info
}

# Change the prompt based on whether we're in insert or command mode.
# TODO: This doesn't reset if you hit ^C to kill your current line.
function zle-keymap-select {
	ZSH_PROMPT_GLYPH="${${KEYMAP/vicmd/${ZSH_CMD_MODE_GLYPH}}/(main|viins)/${ZSH_INS_MODE_GLYPH}}"
	zle reset-prompt
}
zle -N zle-keymap-select
function zle-line-finish {
	ZSH_PROMPT_GLYPH=$ZSH_INS_MODE_GLYPH
}
zle -N zle-line-finish
ZSH_PROMPT_GLYPH=$ZSH_INS_MODE_GLYPH

# Default new command lines to insert mode?
#zle-line-init() { zle -K vicmd; }
#zle -N zle-line-init
#
function git_prompt_info() {
	echo "$vcs_info_msg_0_"
}

# Environment Variables
export PATH=/usr/local/sbin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export MYSQL_PS1="\d> "

# disable full ssh host completion on yakko because SLOOOOOW
function global_ssh_hosts() {
	case $fullname in
		yakko*) return;;
		*) return (${${${${(f)"$(</etc/ssh/ssh_known_hosts)"}:#[\|]*}%%\ *}%%,*});;
	esac
}

# set PATH so it includes user's private bin, local/bin and tools
# directories if they exist
if [ -d ~/bin ] ; then
	PATH=~/bin:"${PATH}"
	export PATH
fi
if [ -d ~/local/bin ] ; then
	PATH=~/local/bin:"${PATH}"
	export PATH
fi
if [ -d ~/tools ] ; then
	PATH=~/tools:"${PATH}"
	export PATH
fi
if [ -d ~/go/bin ] ; then
	PATH=~/go/bin:"${PATH}"
	export PATH
fi


# Python environment variables
if [[ $machine_type =~ ':python' ]]; then
	export PROJECT_HOME="$HOME/projects"
	export PIP_REQUIRE_VIRTUALENV=true
	export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
	function syspip {
		PIP_REQUIRE_VIRTUALENV="" pip $@
	}
fi

# Go environment variables
if [[ $machine_type =~ ':go' ]]; then
	export GOPATH="$HOME/go"
fi

# Mac (and not-mac) things
if [[ $machine_type =~ ':mac' ]]; then
	export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
	PATH="/Users/kylem/perl5/bin${PATH:+:${PATH}}"; export PATH;
	PERL5LIB="/Users/kylem/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
	PERL_LOCAL_LIB_ROOT="/Users/kylem/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
	PERL_MB_OPT="--install_base \"/Users/kylem/perl5\""; export PERL_MB_OPT;
	PERL_MM_OPT="INSTALL_BASE=/Users/kylem/perl5"; export PERL_MM_OPT;
fi


# Work paths and aliases
if [[ $machine_type =~ ':ndn' ]]; then
	export NDN_ROOT="$HOME/ndn/"
	export SITEPANEL_ROOT="$HOME/sitepanel/"
	export NDN_DEV_PORT=9898

	if [ -d /ndn ] ; then
		PATH="/ndn/perl/bin:/ndn/bin:/ndn/dh/bin:$PATH"
		export PATH
	fi
	PATH="$NDN_ROOT/perl/bin:$NDN_ROOT/bin:$NDN_ROOT/dh/bin:$PATH"

	alias dbc="nocorrect dbc"
	alias reboot="/usr/local/ndn/dh/bin/reboot.pl"
	alias rssh="ssh -l root"
	alias servicectl="/usr/bin/sudo /dh/bin/servicectl"
	alias sc="/usr/bin/sudo /dh/bin/servicectl"
	alias sctl="/usr/bin/sudo /dh/bin/servicectl"
	alias mysc="/usr/bin/sudo /usr/bin/env DH_TEMPLATE_PREFIX=/home/kylem/ndn PERLLIB=/home/kylem/ndn/perl/ /home/kylem/ndn/dh/bin/servicectl"
	alias scdb="/usr/bin/sudo /usr/bin/env PERL7DB='BEGIN { require \"perl5db.pl\"; push @DB::typeahead, \"b 824\"; }' DH_TEMPLATE_PREFIX=/home/kylem/ndn PERLLIB=/home/kylem/ndn/perl/ perl -d /home/kylem/ndn/dh/bin/servicectl"
	alias eperl="/opt/plack/perl/bin/perl"

	function rscp { scp $1 root@$2 }
	function rekey  { /usr/bin/sudo /dh/bin/servicectl $1:man authorizedkeys ; }
	function rhost {
		LOOKUP=`host $1 | grep 'has address' | awk '{print $4'}`
		echo `host $LOOKUP | awk '{print $5}'`
	}
	source $HOME/ndn/etc/ndnperl.rc

fi

################
# SSH-y things #
################

function tarfu {
	add-ndn-keys
	ssh kylem@tarfu.dreamhost.com
}
function fubar {
	add-ndn-keys
	ssh kylem@fubar.dreamhost.com
}
function yakko {
	add-ndn-keys
	ssh kylem@yakko.sd.dreamhost.com
}
SSH_ENV="$HOME/.ssh/environment"

# add appropriate ssh keys to the agent
function add-personal-keys {
	# test whether standard identities have been added to the agent already
	if [ -f ~/.ssh/id_rsa ]; then
		ssh-add -l | grep "id_rsa" > /dev/null
		if [ $? -ne 0 ]; then
			ssh-add -t 432000 # Basic ID active for 5 days
			# $SSH_AUTH_SOCK broken so we start a new proper agent
			if [ $? -eq 2 ];then
				start_agent
			fi
		fi
	fi
}

# Encrypt everything in the given directory that isn't a dotfile or already a
# .asc file #FIXME: Better way to detect encrypted file?
function encdir {
	if [[ $machine_type =~ ':mac' ]]; then
		find $* -type f ! -name '*.asc' ! -name '.*' -exec gpg --encrypt --armor -r kmarsh {} \; -exec rm -P {} \;
	else
		find $* -type f ! -name '*.asc' ! -name '.*' -exec gpg --encrypt --armor -r kmarsh {} \; -exec shred {} \;
	fi
}

# Encrypt *everything* in the given directory, even dotfiles and .asc files
function encall {
	if [[ $machine_type =~ ':mac' ]]; then
		find $* -type f -exec gpg --encrypt --armor -r kmarsh {} \; -exec rm -P {} \;
	else
		find $* -type f -exec gpg --encrypt --armor -r kmarsh {} \; -exec shred {} \;
	fi

}

function add-ndn-keys {
	ssh-add -l | grep "ndn\.rsa" > /dev/null
	if [ $? -ne 0 ]; then
		ssh-add -t 32400 ~/.ssh/*-ndn.rsa # NDN IDs active for 9 hours
		# $SSH_AUTH_SOCK broken so we start a new proper agent
		if [ $? -eq 2 ];then
			start_agent
		fi
	fi
}

# start the ssh-agent
function start_agent {
	echo "Initializing new SSH agent..."
	# spawn ssh-agent
	ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
	echo succeeded
	chmod 600 "$SSH_ENV"
	. "$SSH_ENV" > /dev/null
	add-personal-keys
}

function reset_ssh_auth {
	if [ -f "$SSH_ENV" ]; then
	. "$SSH_ENV" > /dev/null
	fi
	ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
	if [ $? -eq 0 ]; then
		add-personal-keys
	else
		start_agent
	fi
}

# check for running ssh-agent with proper $SSH_AGENT_PID
if [ -n "$SSH_AGENT_PID" ]; then
	ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
	if [ $? -eq 0 ]; then
		add-personal-keys
	fi
# if $SSH_AGENT_PID is not properly set, we might be able to load one from
# $SSH_ENV
else
	if [ -f "$SSH_ENV" ]; then
		. "$SSH_ENV" > /dev/null
	fi
	ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
	if [ $? -eq 0 ]; then
		add-personal-keys
	else
		start_agent
	fi
fi


test -e "${HOME}/.iterm2/shell_integration.zsh" && source "${HOME}/.iterm2/shell_integration.zsh"

