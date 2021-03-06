# Aliases
alias ss='thin --stats "/thin/stats" start'
alias sg='ruby script/generate'
alias sd='ruby script/destroy'
alias sp='ruby script/plugin'
alias ssp='ruby script/spec'
alias rdbm='rake db:migrate'
alias sc='ruby script/console'
alias sd='ruby script/server --debugger'
alias devlog='tail -f log/development.log'

# Functions
function rails-remote-console() {
  /usr/bin/env ssh "$1" "( cd "$2" && ruby script/console production )"
}

