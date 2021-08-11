# @author Jeremy Hettenhouser
#
# Sources
# https://github.com/zdharma/zinit-configs/blob/master/numToStr/zshrc.zsh

# profiling
# zmodload zsh/zprof

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  local DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  if [[ ${DISTRIB} = "Ubuntu"* ]]; then
    if uname -a | grep -q '^Linux.*Microsoft'; then
      # ubuntu via WSL Windows Subsystem for Linux

      # Hack: Solve slow FZF issue
      unsetopt PATH_DIRS 
    else
      # native ubuntu
    fi
  elif [[ ${DISTRIB} = "Debian"* ]]; then
    # debian
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS OSX
fi

# MacOs Configuration
export CLICOLOR=1

# Universal
# do not beep at me dammit
setopt NO_BEEP
# no c-s/c-q output freezing
setopt NO_FLOW_CONTROL
# allow expansion in prompts
setopt PROMPT_SUBST
# display PID when suspending processes as well
setopt LONG_LIST_JOBS
# try to avoid the 'zsh: no matches found...'
setopt NONOMATCH
# report the status of backgrounds jobs immediately
setopt NOTIFY
# whenever a command completion is attempted, make sure the entire command path
# is hashed first.
setopt HASH_LIST_ALL
# not just at the end
setopt COMPLETE_IN_WORD
# use zsh style word splitting
setopt NO_SH_WORD_SPLIT
# allow use of comments in interactive code
setopt INTERACTIVE_COMMENTS
# this is default, but set for share_history
setopt APPEND_HISTORY
# If the internal history needs to be trimmed to add the current command line, setting this option will cause the oldest history event that has a duplicate to be lost before losing a unique event from the list. You should be sure to set the value of HISTSIZE to a larger number than SAVEHIST in order to give you some room for the duplicated events, otherwise this option will behave just like HIST_IGNORE_ALL_DUPS once the history fills up with unique events.
setopt HIST_EXPIRE_DUPS_FIRST
# When searching for history entries in the line editor, do not display duplicates of a line previously found, even if the duplicates are not contiguous.
setopt HIST_FIND_NO_DUPS
# If a new command line being added to the history list duplicates an older one, the older command is removed from the list (even if it is not the previous event).
setopt HIST_IGNORE_ALL_DUPS

## History.
HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"
HISTSIZE=100000
SAVEHIST=5000
setopt appendhistory notify
unsetopt beep nomatch

# Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node \

# End of Zinit's installer chunk

## Self update
# zinit self-update

# Plugin update
# cdzinit update

## Prompt
zinit lucid for \
    as"command" from"gh-r" atinit'export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"' atload'eval "$(starship init zsh)"' bpick'*unknown-linux-gnu*' \
    starship/starship \
## End Prompt


## Zinit Packages
zinit pack for fzf
# zinit pack for pyenv

# hacks
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # trace down the plugin that's overriding ^R

## Oh My Zsh plugins, libraries, and functions
setopt promptsubst

zinit lucid for \
    atinit"HIST_STAMPS=dd.mm.yyyy" \
    OMZL::history.zsh \

zinit wait lucid for \
	OMZL::clipboard.zsh \
	OMZL::compfix.zsh \
	OMZL::correction.zsh \
    atload"
        alias ..='cd ..'
        alias ...='cd ../..'
        alias ....='cd ../../..'
        alias .....='cd ../../../..'
    " \
	OMZL::directories.zsh \
	OMZL::git.zsh \
	OMZL::grep.zsh \
	OMZL::termsupport.zsh \
    OMZ::plugins/git-auto-fetch/git-auto-fetch.plugin.zsh \
    atload"
        alias gcd='gco dev'
    " \
	OMZP::git \
    OMZP::colored-man-pages \
    OMZP::mvn \
    OMZP::npm \
    OMZP::vscode \
    OMZP::python \
    OMZP::aws \
    atload"
        alias dcupb='docker-compose up --build'
    " \
	OMZP::docker-compose \
	as"completion" \
    djui/alias-tips 

# zsh github plugins
#TODO pyenv Does not work past cloning    

zinit wait lucid for \
light-mode atinit"ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
light-mode atinit"
    typeset -gA FAST_HIGHLIGHT;
    FAST_HIGHLIGHT[git-cmsg-len]=100;
    zpcompinit;
    zpcdreplay;
" \
    zdharma/fast-syntax-highlighting \
light-mode blockf atpull'zinit creinstall -q .' \
atinit"
    zstyle ':completion:*' completer _expand _complete _ignored _approximate
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*' menu select=2
    zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
    zstyle ':completion:*:descriptions' format '-- %d --'
    zstyle ':completion:*:processes' command 'ps -au$USER'
    zstyle ':completion:complete:*:options' sort false
    zstyle ':fzf-tab:complete:_zlua:*' query-string input
    zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm,cmd -w -w'
    zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
    zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always ${~ctxt[hpre]}$in'
" \
    zsh-users/zsh-completions \
bindmap"^R -> ^H" atinit"
    zstyle :history-search-multi-word page-size 10
    zstyle :history-search-multi-word highlight-color fg=red,bold
    zstyle :plugin:history-search-multi-word reset-prompt-protect 1
" \
    zdharma/history-search-multi-word \
reset \
atclone"local P=${${(M)OSTYPE:#*darwin*}:+g}
        \${P}sed -i \
        '/DIR/c\DIR 38;5;63;1' LS_COLORS; \
        \${P}dircolors -b LS_COLORS > c.zsh" \
atpull'%atclone' pick"c.zsh" nocompile'!' \
atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”' \
    trapd00r/LS_COLORS \
    lukechilds/zsh-nvm \
    paulirish/git-open 
# has'pyenv' on-update-of="$(pyenv root)/bin" atclone'PREFIX="$(pyenv root)/plugins/pyenv-virtualenvwrapper" ./install.sh' wait'1' cloneonly \
#    light-mode pyenv/pyenv-virtualenv 

# github programs

zinit ice wait"2" lucid as"program" pick"bin/git-dsf"
zinit load zdharma/zsh-diff-so-fancy

zinit ice wait"2" lucid as"program" pick"bin/git-dsf"
zinit load zdharma/zsh-diff-so-fancy

zinit ice wait"2" lucid from"gh-r" as"program" mv"exa* -> exa" pick"bin/exa"
zinit light ogham/exa

zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# TODO JENV ICE

# Pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Nodejs
export NVM_AUTO_USE=true

# zinit vars
export ZINIT_HOME="${ZDOTDIR:-${HOME/.zinit}}"

##Liquibase
export LIQUIBASE_HOME="$HOME/Development/bitbucket/liquibase/codb/liquibase-3.2.2"

## Scripts:  TODO: Migrate to a dir commen in wsl/linux/mac os
export SCRIPTS_HOME="$HOME/Development/scripts"
export PERSONAL_SCRIPTS_HOME="/Volumes/Google\ Drive/scripts"

## Homebrew
export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_INSECURE_REDIRECT=1

#GPG config
export GPG_TTY=$TTY

# brew install 
# shfmt
# autopep8
# clang-formatß

##Maven
export MAVEN_OPTS="-Xms1024m -Xms2048m -Dmaven.artifact.threads=10"

##IntelliJ
export IDEA_VM_OPTIONS="
-Xms1024m
-Xmx4096m
-XX:ReservedCodeCacheSize=240m
-XX:+UseCompressedOops
-Dfile.encoding=UTF-8
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-XX:CICompilerCount=2
-Dsun.io.useCanonPrefixCache=false
-Djava.net.preferIPv4Stack=true
-Djdk.http.auth.tunneling.disabledSchemes=""
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-Djdk.attach.allowAttachSelf
-Dkotlinx.coroutines.debug=off
-Djdk.module.illegalAccess.silent=true
-Xverify:none
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
-Djavax.net.ssl.trustStore=/usr/local/etc/truststore/dev-20160524-01.truststore
-Djavax.net.ssl.trustStorePassword=changeit"

## Load .env sensitive variables into the shell
if [ -e "$HOME/.env" ]
then
   # TODO fails if the .env is blank
   export $(egrep -v '^#' "$HOME/.env" | xargs)
else
    touch "$HOME/.env"
fi

# Functions
# Load all files from .shell/zshrc.d directory
if [ -d $HOME/.shellrc/zshrc.d ]; then
  for file in $HOME/.shellrc/zshrc.d/*.zsh; do
    source $file
  done
fi

# Load all files from .shell/rc.d directory
if [ -d $HOME/.shellrc/rc.d ]; then
  for file in $HOME/.shellrc/rc.d/*.sh; do
    source $file
  done
fi

# Aliases
alias cdnginx='cd /usr/local/etc/nginx'
alias zscripts='cd /.shellrc/zshrc.d'

alias psnginx='ps -ef | grep nginx'
alias startnginx='sudo nginx'
alias stopnginx='sudo nginx -s stop'
alias ping='prettyping --nolegend'
alias preview="fzf --preview 'bat --color \"always\" {}'"
alias top="sudo htop"
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"

alias mvncv=mvn clean verify
alias mvnt='mvn clean test -T1.5C'

alias a2inc="$SCRIPTS_HOME/scripts.sh log.a2inc"
alias sql=/opt/sqlcl/bin/sql

# virtual environments
if command -v jenv &> /dev/null
then
    eval "$(jenv init -)"
fi

#TODO pyenv plugins do not zinit correctly
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# end profiling
#zprof
