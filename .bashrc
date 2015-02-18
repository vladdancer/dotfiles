# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
# BASED on http://habrahabr.ru/post/31326/
shopt -s histappend
PROMPT_COMMAND='history -a'

export HISTIGNORE="&:ls:[bf]g:exit"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

_drupal_root() {
  # Go up until we find index.php
  current_dir=`pwd`;
  while [ ${current_dir} != "/" -a -d "${current_dir}" -a \
          ! -f "${current_dir}/index.php" ] ; 
  do
    current_dir=$(dirname "${current_dir}") ;
  done
  if [ "$current_dir" == "/" ] ; then
    exit 1 ;
  else
    echo "$current_dir" ;
  fi 
}

_drupal_modules_in_dir()
{
  COMPREPLY=( $( compgen -W '$( command find $1 -regex ".*\.module" -exec basename {} .module \; 2> /dev/null )' -- $cur  ) )
}

_drupal_modules()
{
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  local drupal_root=`_drupal_root` && \
  _drupal_modules_in_dir "$drupal_root/sites $drupal_root/profiles $drupal_root/modules"
}

_drupal_features_in_dir()
{
  COMPREPLY=( $( compgen -W '$( command find $1 -regex ".*\.features.inc" -exec basename {} .features.inc \; 2> /dev/null )' -- $cur  ) )
}

_drupal_features()
{
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  local drupal_root=`_drupal_root` && \
  _drupal_features_in_dir "$drupal_root/sites $drupal_root/profiles $drupal_root/modules $drupal_root/sites/all/modules/features"
}

cdd()
{
  local drupal_root=`_drupal_root` && \
  if [ "$1" == "" ] ; then
    cd "$drupal_root";
  else
    cd `find $drupal_root -regex ".*/$1\.module" -exec dirname {} \;`
  fi
}

complete -F _drupal_modules dren
complete -F _drupal_modules drdis
complete -F _drupal_features drfr
complete -F _drupal_features drfu
complete -F _drupal_features drfd
complete -F _drupal_modules cdd

#----------------------------------------------
# Include various handy things for bash routine
#----------------------------------------------
. $HOME/.routine.bashrc