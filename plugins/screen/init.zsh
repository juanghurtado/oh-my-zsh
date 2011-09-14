# ------------------------------------------------------------------------------
#          FILE:  screen.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Sorin Ionescu <sorin.ionescu@gmail.com>
#       VERSION:  1.0.0
# ------------------------------------------------------------------------------

# Aliases
alias sl="screen -list"
alias sr="screen -a -A -U -D -R"
alias sn="screen -U -S"

# Auto
if (( $SHLVL == 1 )) && check-bool "$AUTO_SCREEN"; then
  (( SHLVL += 1 )) && export SHLVL
  session="$(screen -list 2> /dev/null | sed '1d;$d' | awk '{print $1}' | head -1)"
  if [[ -n "$session" ]]; then
    exec screen -x "$session"
  else
    exec screen -a -A -U -D -R -m "$SHELL" -l
  fi
fi

