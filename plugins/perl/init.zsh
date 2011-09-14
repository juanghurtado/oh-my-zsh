# For Perl older than 5.10.14, install local::lib.
#   curl -L -C - -O http://search.cpan.org/CPAN/authors/id/A/AP/APEIRON/local-lib-1.008004.tar.gz
#   tar xvf local-lib-1.008004.tar.gz
#   cd local-lib-1.008004
#   perl Makefile.PL --bootstrap=$HOME/Library/Perl/5.12
#   make && make test && make install
#
# Install cpanminus:
#   curl -L http://cpanmin.us | perl - --self-upgrade
#
if [[ "$OSTYPE" == darwin* ]]; then
  # Perl is slow; cache its output.
  cache_file="${0:h}/cache.zsh"
  perl_path="$HOME/Library/Perl/5.12"
  if [[ -f "$perl_path/lib/perl5/local/lib.pm" ]]; then
    export MANPATH="$perl_path/man:$MANPATH"
    if [[ ! -f "$cache_file" ]]; then
      perl -I$perl_path/lib/perl5 -Mlocal::lib=$perl_path >! "$cache_file"
      source "$cache_file"
    else
      source "$cache_file"
    fi
  fi
  unset perl_path
  unset cache_file
fi

# Aliases
alias pbi='perlbrew install'
alias pbl='perlbrew list'
alias pbo='perlbrew off'
alias pbs='perlbrew switch'
alias pbu='perlbrew use'
alias ple='perl -wlne'
alias pd='perldoc'

# Perl Global Substitution
function pgs() {
  if (( $# < 2 )) ; then
    echo "Usage: $0 find replace [file ...]" >&2
    return 1
  fi

  local find="$1"
  local replace="$2"
  repeat 2 shift

  perl -i.orig -pe 's/'"$find"'/'"$replace"'/g' "$@"
}

# Perl grep since 'grep -P' is terrible.
function prep() {
  if (( $# < 1 )) ; then
    echo "Usage: $0 pattern [file ...]" >&2
    return 1
  fi

  local pattern="$1"
  shift

  perl -nle 'print if /'"$pattern"'/;' "$@"
}

