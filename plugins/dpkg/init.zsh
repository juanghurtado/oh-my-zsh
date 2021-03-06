# Debian ZSH Aliases and Functions

# Aliases
alias as="aptitude -F \"* %p -> %d \n(%v/%V)\" --no-gui --disable-columns search" # Search package.
alias ad="sudo apt-get update"                                                    # Update packages lists.
alias au="sudo apt-get update && sudo apt-get dselect-upgrade"                    # Upgrade packages.
alias ai="sudo apt-get install"                                                   # Install package.
alias ar="sudo apt-get remove --purge && sudo apt-get autoremove --purge"         # Remove package.
alias ap="apt-cache policy"                                                       # Apt policy.
alias av="apt-cache show"                                                         # Show package info.
alias acs="apt-cache search"                                                      # Search package.
alias ac="sudo apt-get clean && sudo apt-get autoclean"                           # Clean apt cache.
alias afs='apt-file search --regexp'                                              # Find file's packake.

# Install all .deb files in the current directory.
# WARNING: you will need to put the glob in single quotes if you use glob_subst.
alias debi='su -c "dpkg -i ./*.deb"'

# Create a basic .deb package.
alias debc='time dpkg-buildpackage -rfakeroot -us -uc'

# Remove ALL kernel images and headers EXCEPT the one in use.
alias kclean='su -c '\''aptitude remove -P ?and(~i~nlinux-(ima|hea) ?not(~n`uname -r`))'\'' root'

# Functions

# Create a simple script that can be used to 'duplicate' a system.
function apt-copy() {
  print '#!/bin/sh'"\n" > apt-copy.sh

  list=$(perl -m'AptPkg::Cache' -e '$c=AptPkg::Cache->new; for (keys %$c){ push @a, $_ if $c->{$_}->{'CurrentState'} eq 'Installed';} print "$_ " for sort @a;')

  print 'aptitude install '"$list\n" >> apt-copy.sh

  chmod +x apt-copy.sh
}

# Kernel-package building shortcut.
function dbb-build() {
  MAKEFLAGS=''                  # Temporarily unset MAKEFLAGS ( '-j3' will fail ).
  appendage='-custom'           # This shows up in $ (uname -r ).
  revision=$(date +"%Y%m%d")    # This shows up in the .deb file name.

  make-kpkg clean

  time fakeroot make-kpkg --append-to-version "$appendage" --revision \
    "$revision" kernel_image kernel_headers
}

