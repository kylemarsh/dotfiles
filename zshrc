fullname=`hostname -f 2>/dev/null || hostname`

# What kind of machine is this?
case `uname` in
	Darwin) machine_type="${machine_type}:mac";;
esac

case $fullname in
	*vimes*)
		machine_type="${machine_type}:python:home:go"
		;;
	*etsy.com) ;&
	*etsycloud.com) ;&
	#*etsy.com) ;&
	#*goibniu*)
	10162*)
		machine_type="${machine_type}:etsy"
		;;
esac

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.ohmyzsh
ZSH_THEME="kylemarsh"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true" #oh-my-zsh updates
# DISABLE_AUTO_TITLE="true"
# DISABLE_CORRECTION="true"

base_plugins=(history screen virtualenv)
etsy_plugins=()
python_plugins=(pip virtualenvwrapper)
mac_plugins=(battery brew)

plugins=($base_plugins)
if [[ $machine_type =~ ':mac' ]]; then
	plugins+=($mac_plugins)
fi
if [[ $machine_type =~ ':etsy' ]]; then
	plugins+=($etsy_plugins)
fi
if [[ $machine_type =~ ':python' ]]; then
	plugins+=($python_plugins)
    DISABLE_VENV_CD=1
fi

source $ZSH/oh-my-zsh.sh
fpath=($HOME/lib/zsh/functions $fpath)

## Override things that oh-my-zsh doesn't do right ##
# Turn off the damnable shared history
unsetopt share_history

# Fuzzy Finder:
if [[ ! "$PATH" == *$HOME/dotfiles/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/kmarsh/dotfiles/fzf/bin"
fi
[[ $- == *i* ]] && source "$HOME/dotfiles/fzf/shell/completion.zsh" 2> /dev/null # auto-completion
if [[ -f $HOME/dotfiles/fzf/shell/key-bindings.zsh ]]; then
    source "$HOME/dotfiles/fzf/shell/key-bindings.zsh"
fi
if [[ -f $HOME/dotfiles/zsh/git-fzf.sh ]]; then
    source "$HOME/dotfiles/zsh/git-fzf.sh"
fi


# Git prompt stuff
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
# %s The VCS in use (git, hg, svn, etc.).
# %b Information about the current branch.
# %a An identifier that describes the action. Only makes sense in actionformats.
# %i The current revision number or identifier. For hg the hgrevformat style may be used to customize the output.
# %c The string from the stagedstr style if there are staged changes in the repository.
# %u The string from the unstagedstr style if there are unstaged changes in the repository.
# %R The base directory of the repository.
# %r The repository name. If %R is /foo/bar/repoXY, %r is repoXY.
# %S A subdirectory within a repository. If $PWD is /foo/bar/repoXY/beer/tasty, %S is beer/tasty.
# %m A "misc" replacement. It is at the discretion of the backend to decide what this replacement expands to.
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr "%{$fg[green]%}*"
zstyle ':vcs_info:*' unstagedstr "%{$fg[cyan]%}*"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git svn
precmd() {
	if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
		zstyle ':vcs_info:*' formats "%{$reset_color%}(%{$fg[red]%}%r:%b%{$reset_color%}:%c%u%{$reset_color%})"
	} else {
		zstyle ':vcs_info:*' formats "%{$reset_color%}(%{$fg[red]%}%r:%b%{$reset_color%}:%c%u%{$fg[white]%}*%{$reset_color%})"
	}
	vcs_info
}

function git_prompt_info() {
	echo "$vcs_info_msg_0_"
}

# Environment Variables
export PATH=/usr/local/sbin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export MYSQL_PS1="\d> "
export GPG_TTY=$(tty)

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
    # Homebrew needs this now:
	if [ -f /opt/homebrew/bin/brew ]; then
        eval $(/opt/homebrew/bin/brew shellenv)
    fi

	export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
	PATH="/Users/kylem/perl5/bin${PATH:+:${PATH}}"; export PATH;
	PERL5LIB="/Users/kylem/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
	PERL_LOCAL_LIB_ROOT="/Users/kylem/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
	PERL_MB_OPT="--install_base \"/Users/kylem/perl5\""; export PERL_MB_OPT;
	PERL_MM_OPT="INSTALL_BASE=/Users/kylem/perl5"; export PERL_MM_OPT;
fi


# Work paths and aliases
if [[ $machine_type =~ ':etsy' ]]; then
	# Tail php logs on the VM
	alias tl='sudo tail -f /var/log/httpd/php.log /var/log/httpd/info.log /var/log/httpd/error_log /var/log/gearman/php.log'
    if [ -f ~/development/bin/xdebug_toggle ]; then
        source ~/development/bin/xdebug_toggle
    fi
    if [ -d ~/development/Etsyweb ]; then
        alias plib="nocorrect cd ~/development/Etsyweb/phplib"
        alias plib..="nocorrect cd ~/development/Etsyweb"
        alias punit="nocorrect cd ~/development/Etsyweb/tests/phpunit"
        alias punit..="nocorrect cd ~/development/Etsyweb/tests"
        alias oneoffs="nocorrect cd ~/oneoffs/"
        alias oneoff="nocorrect cd ~/oneoffs/"
        alias olfscript="nocorrect cd ~/development/olf-scripts"
        alias ks="nocorrect cd ~/development/EtsyKafka/kafkastreams"
        alias olfks="nocorrect cd ~/development/EtsyKafka/kafkastreams/olf/src/main/java/com/etsy/streams"
        alias run-phpunit="~/development/Etsyweb/vendor/bin/run-phpunit"
        alias sparkly="nocorrect cd ~/development/sparkly"
    fi

    if [ -f ~/bin/cloudsnooze ]; then
        source ~/bin/cloudsnooze
    fi

    # put Google Cloud SDK in PATH and enable shell command completion for gcloud.
    if [ -f '/Users/kmarsh/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kmarsh/google-cloud-sdk/path.zsh.inc'; fi
    if [ -f '/Users/kmarsh/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kmarsh/google-cloud-sdk/completion.zsh.inc'; fi

    alias ksd='kubectl --cluster gke_etsy-kafka-gke-dev_us-central1_kafka-gke-dev --namespace kafkastreams'
    alias ksp='kubectl --cluster gke_etsy-kafka-gke-prod_us-central1_kafka-gke-prod --namespace kafkastreams'
    alias td='kubectl --cluster gke_etsy-kafka-gke-dev_us-central1_kafka-gke-dev --namespace tanuki'
    alias tp='kubectl --cluster gke_etsy-kafka-gke-prod_us-central1_kafka-gke-prod --namespace tanuki'
fi

################
# SSH-y things #
################

function gvm {
	add-etsy-keys
	ssh kmarsh@kmarsh-search.vm.dev.etsycloud.com
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
				start_ssh_agent
			fi
		fi
	fi
}

function add-etsy-keys {
	ssh-add -l | grep "etsy\.rsa" > /dev/null
	if [ $? -ne 0 ]; then
		ssh-add -t 32400 ~/.ssh/*-etsy.rsa # Etsy IDs active for 9 hours
		# $SSH_AUTH_SOCK broken so we start a new proper agent
		if [ $? -eq 2 ];then
			start_ssh_agent
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

# start the ssh-agent
function start_ssh_agent {
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
		start_ssh_agent
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
		start_ssh_agent
	fi
fi

function obj {
	aws --endpoint-url https://objects-us-west-1.dream.io s3 $@
}

function pullall() {
    for i in `find $1 -maxdepth 2 -type d -name .git -exec dirname {} \;`
    do
        echo $i
        git -C $i pull --rebase
    done
}

function page() {
    tail -n+$2 $3 | head -$1
}


# Make man's output colorized:
function man() {
    env \ LESS_TERMCAP_mb=$(printf "\x1b[38;2;255;200;200m") \
        LESS_TERMCAP_md=$(printf "\x1b[38;2;255;100;200m") \
        LESS_TERMCAP_me=$(printf "\x1b[0m") \
        LESS_TERMCAP_so=$(printf "\x1b[38;2;60;90;90;48;2;40;40;40m") \
        LESS_TERMCAP_se=$(printf "\x1b[0m") \
        LESS_TERMCAP_us=$(printf "\x1b[38;2;150;100;200m") \
        LESS_TERMCAP_ue=$(printf "\x1b[0m") \
        man "$@"
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kmarsh/bin/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kmarsh/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kmarsh/bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kmarsh/bin/google-cloud-sdk/completion.zsh.inc'; fi
