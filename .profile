set -o vi
##
#   Local aliases
alias ls='ls -G'
alias l='ls'
alias lh='ls -lat | head'
alias ll='ls -lh --color=auto'
alias la='ls -la'
alias dhog='du -x --block-size=1024K | sort -nr | head'
alias l20='ls -lAt | head -20'
alias ff='find -type f'
alias grep='grep --color=auto'
alias view='/usr/bin/vim -R'
alias h='history | tail'
alias c='clear'
alias myprocesses='ps -ef | grep $USER'
alias screen="screen -R"

##
#  ignore .svn dirs
export FIGNORE=.svn

##
#  Lets only give ant a bit of our memory not all
export ANT_OPTS="-Xmx1G"

ant() {
    /usr/bin/ant "$@" | color_highlighter
}

adb() {
    /opt/android/platform-tools/adb "$@" | color_highlighter
}

mvn() {
    /usr/bin/mvn "$@" | color_highlighter
}

##
#  set the number of open files to be 1024
ulimit -S -n 1024

##
# Ruby
export RUBY_VERSION=1.9.2
export PATH=$PATH:$HOME/.gem/ruby/$RUBY_VERSION/bin

##
# HOME BIN
export PATH=$PATH:$HOME/bin:/usr/local/mysql/bin

##
#   Android Development
export ANDROID_HOME="/opt/android"
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

##
#   SVN
export SVN_EDITOR=vim

setprompt() {
    #PS1="\n\[\e[1;37;29m\][\u@\h[0m[1;37m] \w \[\e[0m\]\n\$ "
    source $HOME/.bash_dont_think.sh
}

#export default env vars.
export CFLAGS='-Wall -pedantic'
export CC=`which gcc`
export EDITOR=`which vim`
export PROMPT_COMMAND=setprompt
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"

if [ -f $HOME/.Xdefaults ]; then
  xrdb -merge $HOME/.Xdefaults
  export TERM=xterm-256color
fi

[[ -s "/Users/mlemley/.rvm/scripts/rvm" ]] && source "/Users/mlemley/.rvm/scripts/rvm"  # This loads RVM into a shell session.

export PATH=$PATH:$HOME/homebrew/bin

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

if [ -f $(brew --prefix)/etc/profile.d/z.sh ]; then
    . `brew --prefix`/etc/profile.d/z.sh
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
