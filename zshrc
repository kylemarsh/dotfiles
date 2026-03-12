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
	*etsy-devenv-web-prod*) ;&
	#*etsy.com) ;&
	#*goibniu*)
	10162*)
		machine_type="${machine_type}:etsy"
		;;
esac

# Set primary SSH key based on machine type
if [[ $machine_type =~ ':etsy' ]]; then
    primary_ssh_key="$HOME/.ssh/creidhne-etsy.rsa"
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
    primary_ssh_key="$HOME/.ssh/id_ed25519"
elif [ -f "$HOME/.ssh/id_rsa" ]; then
    primary_ssh_key="$HOME/.ssh/id_rsa"
fi

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
mac_plugins=(battery brew asdf)

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
if command -v op &> /dev/null; then
    eval "$(op completion zsh)"; compdef _op op
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
if [ -d ~/.local/bin ] ; then
	PATH=~/.local/bin:"${PATH}"
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

alias vit="vim -c Git -c only"

# Work paths and aliases
if [[ $machine_type =~ ':etsy' ]]; then
	# Tail php logs on the VM
	alias tl='sudo tail -f /var/log/httpd/php.log /var/log/httpd/info.log /var/log/httpd/error_log /var/log/gearman/php.log'
    if [ -f ~/development/bin/xdebug_toggle ]; then
        source ~/development/bin/xdebug_toggle
    fi
    if [ -d ~/development/Etsyweb ]; then
        alias emods="nocorrect cd ~/development/Etsyweb/modules"
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
    fi

    if [[ $machine_type =~ ':mac' ]]; then
        alias serverless="docker run --pull always -t --platform linux/amd64 \
-v ~/.config/gcloud:/home/serverless/.config/gcloud \
us-central1-docker.pkg.dev/etsy-batchjobs-prod/serverless-hub/etsy-serverless-cli:latest \
serverless"
        alias sparkly="docker run --pull always -t --platform linux/amd64 \
-v ~/.config/gcloud:/home/serverless/.config/gcloud \
us-central1-docker.pkg.dev/etsy-batchjobs-prod/serverless-hub/etsy-serverless-cli:latest \
sparkly"
        # put Google Cloud SDK in PATH and enable shell command completion for gcloud.
        if [ -f '/Users/kmarsh/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kmarsh/google-cloud-sdk/path.zsh.inc'; fi
        if [ -f '/Users/kmarsh/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kmarsh/google-cloud-sdk/completion.zsh.inc'; fi
    else
        if [ -f '/home/kmarsh/google-cloud-sdk/path.zsh.inc' ]; then . '/home/kmarsh/google-cloud-sdk/path.zsh.inc'; fi
        if [ -f '/home/kmarsh/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/kmarsh/google-cloud-sdk/completion.zsh.inc'; fi
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    alias ksd='kubectl --cluster gke_etsy-kafka-gke-dev_us-central1_kafka-gke-dev --namespace kafkastreams'
    alias ksp='kubectl --cluster gke_etsy-kafka-gke-prod_us-central1_kafka-gke-prod --namespace kafkastreams'
    alias td='kubectl --cluster gke_etsy-kafka-gke-dev_us-central1_kafka-gke-dev --namespace tanuki'
    alias tp='kubectl --cluster gke_etsy-kafka-gke-prod_us-central1_kafka-gke-prod --namespace tanuki'
fi

################
# SSH-y things #
################

SSH_ENV="$HOME/.ssh/environment"

# add appropriate ssh keys to the agent
function unlock-ssh {
    # Check if agent is reachable
    ssh-add -l &>/dev/null
    local ret=$?
    if [ $ret -eq 2 ]; then
        return 1
    fi

    # Check if primary key is set
    if [ -z "$primary_ssh_key" ]; then
        echo "Error: primary_ssh_key is not set"
        return 1
    fi

    # Check if primary key file exists
    if [ ! -f "$primary_ssh_key" ]; then
        echo "Error: primary key file not found: $primary_ssh_key"
        return 1
    fi

    # Get fingerprint of the primary key
    local primary_fingerprint=$(ssh-keygen -lf "$primary_ssh_key" 2>/dev/null | awk '{print $2}')
    if [ -z "$primary_fingerprint" ]; then
        echo "Error: could not get fingerprint of $primary_ssh_key"
        return 1
    fi

    # Check if primary key is already in the agent
    ssh-add -l | grep -q "$primary_fingerprint"
    if [ $? -eq 0 ]; then
        return 0
    fi

    # Add the primary key to the agent
    ssh-add -t 432000 "$primary_ssh_key"
}

# start the ssh-agent
function ssh-start-agent {
    pgrep ssh-agent > /dev/null
    if [ $? -eq 0 ]; then
        killall ssh-agent
    fi
	ssh-agent > "$SSH_ENV"
	chmod 600 "$SSH_ENV"
	. "$SSH_ENV" > /dev/null
    unlock-ssh
}

# use this if a shell is using an ssh-agent process that isn't the one
# referenced in ~/.ssh/environment
function ssh-sync-agent {
    OLD_PID=$SSH_AGENT_PID
    if [ -f "$SSH_ENV" ]; then
        . "$SSH_ENV"
    else
        ssh-start-agent
        return
    fi

    if [ -n "$OLD_PID" ] && [ "$OLD_PID" -ne "$SSH_AGENT_PID" ]; then
        kill $OLD_PID 2>/dev/null
    fi
}

# Test if an agent is actually usable by trying to list keys
function ssh-agent-is-usable {
    if [ -z "$SSH_AGENT_PID" ] || [ -z "$SSH_AUTH_SOCK" ]; then
        return 1
    fi

    # Check if the PID is a running ssh-agent process
    # Use 'ps -p PID -o comm=' for cross-platform compatibility
    if ps -p "$SSH_AGENT_PID" -o comm= 2>/dev/null | grep -q ssh-agent; then
        # Check if the socket is actually usable
        if [ -S "$SSH_AUTH_SOCK" ]; then
            # Try to communicate with the agent
            ssh-add -l &>/dev/null
            local ret=$?
            # Return codes: 0 = keys loaded, 1 = no keys but agent works, 2 = agent broken
            if [ $ret -ne 2 ]; then
                return 0
            fi
        fi
    fi
    return 1
}

## Set up ssh-agent for this shell:
# Try to load agent info from environment file if not already set
if [ -z "$SSH_AGENT_PID" ] || [ -z "$SSH_AUTH_SOCK" ]; then
	if [ -f "$SSH_ENV" ]; then
		. "$SSH_ENV" > /dev/null
	fi
fi

# Test if we have a usable agent
if ssh-agent-is-usable; then
    unlock-ssh
else
    # Agent not usable - try reloading from environment file in case it's stale
    if [ -f "$SSH_ENV" ]; then
        . "$SSH_ENV" > /dev/null
        if ssh-agent-is-usable; then
            unlock-ssh
        else
            # Still not usable, start a new one
            ssh-start-agent
        fi
    else
        # No environment file, start a new agent
        ssh-start-agent
    fi
fi

function vpbcopy() {
    if [ -z $SSH_CLIENT ]; then
        echo "not connected via ssh"
        return -1
    fi
    ssh `echo $SSH_CLIENT | awk '{print $1}'` pbcopy;
}

function vpbpaste() {
    if [ -z $SSH_CLIENT ]; then
        echo "not connected via ssh"
        return -1
    fi
    ssh `echo $SSH_CLIENT | awk '{print $1}'` pbpaste;
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

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv > /dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
if [[ $(pyenv --version) == "pyenv 2.3.17" ]]; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if [[ $machine_type =~ ':mac' ]]; then
    export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig"
    export LDFLAGS="-L/opt/homebrew/lib"
    export CPPFLAGS="-I/opt/homebrew/include"
    eval "$(pyenv virtualenv-init -)"
fi

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc

# Claude code:
export PATH="$HOME/.asdf/shims:$PATH"
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=etsy-claude-code-sandbox
