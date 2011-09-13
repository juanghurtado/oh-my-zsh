setopt correct        # Correct commands.
setopt correct_all    # Correct all arguments.

# The 'ls' Family
if [[ "$DISABLE_COLOR" != 'true' ]]; then
  if [[ -f "$HOME/.dir_colors" ]] && ( (( $+commands[dircolors] )) || ( (( $+plugins[(er)gnu-utils] )) && (( $+commands[gdircolors] )) ) ); then
    eval $("${commands[dircolors]:-$commands[gdircolors]}" "$HOME/.dir_colors")
    alias ls='ls -hF --group-directories-first --color=auto'
  else
    export CLICOLOR=1
    export LSCOLORS="exfxcxdxbxegedabagacad"
    alias ls='ls -G -F'
  fi
fi

alias l1='ls -1A'            # Show files in one column.
alias ll='ls -lh'            # Show human readable.
alias la='ls -lhA'           # Show hidden files.
alias lx='ls -lhXB'          # Sort by extension.
alias lk='ls -lhSr'          # Sort by size, biggest last.
alias lc='ls -lhtcr'         # Sort by and show change time, most recent last.
alias lu='ls -lhtur'         # Sort by and show access time, most recent last.
alias lt='ls -lhtr'          # Sort by date, most recent last.
alias lm='ls -lha | more'    # Pipe through 'more'.
alias lr='ls -lhR'           # Recursive ls.
alias sl='ls'                # I often screw this up.

# General
alias cd='nocorrect cd'
alias cp='nocorrect cp -i'
alias find='noglob find'
alias gcc='nocorrect gcc'
alias ln='nocorrect ln -i'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir -p'
alias mv='nocorrect mv -i'
alias rm='nocorrect rm -i'
alias scp='nocorrect scp'
alias df='df -kh'
alias du='du -kh'
alias po='popd'
alias pu='pushd'
alias _='sudo'
alias b="$BROWSER"
alias e="$EDITOR"
alias v="$PAGER"
alias history='fc -l 1'
alias type='type -a'
alias ssh='ssh -X'

# Mac OS X
if [[ "$OSTYPE" != darwin* ]]; then
  alias open='xdg-open'
  alias get='wget --continue --progress=bar'

  if (( $+commands[xclip] )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  fi

  if (( $+commands[xsel] )); then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
else
  alias get='curl --continue-at - --location --progress-bar --remote-name'
fi

alias o='open'
alias pbc='pbcopy'
alias pbp='pbpaste'

# Top
if (( $+commands[htop] )); then
  alias top=htop
else
  alias topm='top -o vsize'
  alias topc='top -o cpu'
fi

# Diff/Make
if [[ "$DISABLE_COLOR" != 'true' ]]; then
  if (( $+commands[colordiff] )); then
    alias diff='colordiff -u'
    compdef colordiff=diff
  elif (( $+commands[git] )); then
    function diff() {
      git --no-pager diff --color=always --no-ext-diff --no-index "$@";
    }
    compdef _git diff=git-diff
  else
    alias diff='diff -u'
  fi

  if (( $+commands[colormake] )); then
    alias make='colormake'
    compdef colormake=make
  fi
fi

# Terminal Multiplexer
alias sl="screen -list"
alias sr="screen -a -A -U -D -R"
alias sn="screen -U -S"

if (( $+commands[tmux] )); then
  alias tl="tmux list-sessions"
  alias ta="tmux attach-session"
fi

# Miscellaneous
(( $+commands[ack] )) && alias afind='ack -il'
(( $+commands[ebuild] )) && alias ebuild='nocorrect ebuild'
(( $+commands[gist] )) && alias gist='nocorrect gist'
(( $+commands[heroku] )) && alias heroku='nocorrect heroku'
(( $+commands[hpodder] )) && alias hpodder='nocorrect hpodder'
(( $+commands[mysql] )) && alias mysql='nocorrect mysql'

