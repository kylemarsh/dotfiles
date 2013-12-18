fullname=`hostname -f 2>/dev/null || hostname`

# What kind of machine is this?
case `uname` in
	Darwin) machine_type="$machine_type:mac";;
esac

case $fullname in
	*lilypad*)
		machine_type="$machine_type:python:home"
		;;
	*dreamhost.com) ;&
	*newdream.net)
		machine_type="$machine_type:ndn"
		;;
esac

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# set ZSH_THEME to "random" for random theme on each load
ZSH_THEME="kylemarsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
#DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
base_plugins=(git history history-substring-search screen vi-mode virtualenv)
ndn_plugins=(perl)
python_plugins=(pip virtualenvwrapper)
mac_plugins=(battery brew terminalapp)

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

## Override things that oh-my-zsh doesn't do right ##
# Turn off the damnable shared history
unsetopt share_history

# make vi bindings useful (more vim; less vi)
set -o vi
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^?' backward-delete-char
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[3~' delete-char

# Environment Variables

export PATH=/usr/local/bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export MYSQL_PS1="\d> "

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


# Python environment variables
if [[ $machine_type =~ ':python' ]]; then
	export PROJECT_HOME="$HOME/projects"
	export PIP_REQUIRE_VIRTUALENV=true
	export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
	function syspip {
		PIP_REQUIRE_VIRTUALENV="" pip $@
	}
fi

# Mac (and not-mac) things
if [[ $machine_type =~ ':mac' ]]; then
	export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
else
	dircolors=~/dotfiles/dircolors.ansi-dark
	test -r $dircolors && eval "$(dircolors $dircolors)"
fi


# Work paths and aliases
if [[ $machine_type =~ ':ndn' ]]; then
	if [ -d ~/ndn/perl ] ; then
		PERL5LIB=~/ndn/perl
		export PERL5LIB
	fi
	if [ -d /ndn/dh/bin ] ; then
		PATH=/ndn/dh/bin:"${PATH}"
		export PATH
	fi

	alias reboot="/usr/local/ndn/dh/bin/reboot.pl"
	alias rssh="ssh -l root"
	alias servicectl="/usr/bin/sudo /dh/bin/servicectl"
	alias sc="/usr/bin/sudo /dh/bin/servicectl"
	alias sctl="/usr/bin/sudo /dh/bin/servicectl"
	alias mysc="/usr/bin/sudo /usr/bin/env DH_TEMPLATE_PREFIX=/home/kylem/ndn PERLLIB=/home/kylem/ndn/perl/ /home/kylem/ndn/dh/bin/servicectl"
	alias scdb="/usr/bin/sudo /usr/bin/env PERL5DB='BEGIN { require \"perl5db.pl\"; push @DB::typeahead, \"b 815\"; }' DH_TEMPLATE_PREFIX=/home/kylem/ndn PERLLIB=/home/kylem/ndn/perl/ perl -d /home/kylem/ndn/dh/bin/servicectl"

	function rscp { scp $1 root@$2 }
	function rekey  { /usr/bin/sudo /dh/bin/servicectl $1:man authorizedkeys ; }
	function rhost {
		LOOKUP=`host $1 | grep 'has address' | awk '{print $4'}`
		echo `host $LOOKUP | awk '{print $5}'`
	}

fi

################
# SSH-y things #
################

function fubar { ssh kylem@fubar.dreamhost.com }
function yakko { ssh kylem@yakko.sd.dreamhost.com }
SSH_ENV="$HOME/.ssh/environment"

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
    echo succeeded
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
    ssh-add
}

# test for identities
function test_identities {
    # test whether standard identities have been added to the agent already
    ssh-add -l | grep "The agent has no identities" > /dev/null
    if [ $? -eq 0 ]; then
        ssh-add
        # $SSH_AUTH_SOCK broken so we start a new proper agent
        if [ $? -eq 2 ];then
            start_agent
        fi
    fi
}

function reset_ssh_auth {
	if [ -f "$SSH_ENV" ]; then
	. "$SSH_ENV" > /dev/null
	fi
    ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
    if [ $? -eq 0 ]; then
        test_identities
    else
        start_agent
    fi
}

# check for running ssh-agent with proper $SSH_AGENT_PID
if [ -n "$SSH_AGENT_PID" ]; then
    ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
    if [ $? -eq 0 ]; then
	test_identities
    fi
# if $SSH_AGENT_PID is not properly set, we might be able to load one from
# $SSH_ENV
else
    if [ -f "$SSH_ENV" ]; then
	. "$SSH_ENV" > /dev/null
    fi
    ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
    if [ $? -eq 0 ]; then
        test_identities
    else
        start_agent
    fi
fi

