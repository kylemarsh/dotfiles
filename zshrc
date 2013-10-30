# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="kylemarsh"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)

plugins=(git battery brew history history-substring-search screen terminalapp vi-mode)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

##############
##############
# klm's zshrc -- MacBook Verson
# adapted from twb's /zshrc_common
# adapted from mbp's /zshrc_common

# Environment Variables
fullname=`hostname -f 2>/dev/null || hostname`

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LD_LIBRARY_PATH='/usr/local/lib'
export PROJECT_HOME="$HOME/proj"

if [ -d ~/ndn/perl ] ; then
	PERL5LIB=~/ndn/perl
	export PERL5LIB
fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
    export PATH
fi
if [ -d ~/local/bin ] ; then
    PATH=~/local/bin:"${PATH}"
    export PATH
fi

# set PATH so it includes /ndn/dh/bin if it exists
if [ -d /ndn/dh/bin ] ; then
    PATH=/ndn/dh/bin:"${PATH}"
    export PATH
fi

# set PATH so it includes ~/tools if it exists
if [ -d ~/tools ] ; then
    PATH=~/tools:"${PATH}"
    export PATH
fi

work_user='kylem'
home_user='kmarsh'

function home_user { echo ${home_user} }
function work_user { echo ${work_user} }

# work aliases -- should only happen on yakko, actually...need to figure out
# how to enforce that.
alias reboot="/usr/local/ndn/dh/bin/reboot.pl"
alias rssh="ssh -l root"
alias servicectl="/usr/bin/sudo /dh/bin/servicectl"
alias sc="/usr/bin/sudo /dh/bin/servicectl"
alias sctl="/usr/bin/sudo /dh/bin/servicectl"
alias mysc="/usr/bin/sudo /usr/bin/env DH_TEMPLATE_PREFIX=/home/kylem/ndn PERLLIB=/home/kylem/ndn/perl/ /home/kylem/ndn/dh/bin/servicectl"
#alias scdb="/usr/bin/sudo /usr/bin/env PERLLIB=/home/kylem/ndn/perl/ perl -d /home/kylem/ndn/dh/bin/servicectl"
alias scdb="/usr/bin/sudo /usr/bin/env PERL5DB='BEGIN { require \"perl5db.pl\"; push @DB::typeahead, \"b 803\"; }' DH_TEMPLATE_PREFIX=/home/kylem/ndn PERLLIB=/home/kylem/ndn/perl/ perl -d /home/kylem/ndn/dh/bin/servicectl"

function rscp { scp $1 root@$2 }

function rekey  { /usr/bin/sudo /dh/bin/servicectl $1:man authorizedkeys ; }

function rhost {
	LOOKUP=`host $1 | grep 'has address' | awk '{print $4'}`
	echo `host $LOOKUP | awk '{print $5}'`
}

# DreamHost machines
function fubar { ssh ${work_user}@fubar.dreamhost.com }
function yakko { ssh ${work_user}@yakko.sd.dreamhost.com }

# MySQL Prompt
#export MYSQL_PS1="$(print '\e[1;31m')\d$(print '\e[0m')> "
export MYSQL_PS1="\d> "

# Set up ls colors for solarized
if [[ $(uname) == "Darwin" ]] ; then
	export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
elif [[ $(uname) == "Linux" ]] ; then
	dircolors=~/dotfiles/dircolors.256dark
	test -r $dircolors && eval "$(dircolors $dircolors)"
fi

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

