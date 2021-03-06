# The default styles.
zstyle ':git-info:' action    'action:%s'       #  %s - Special action name (am, merge, rebase).
zstyle ':git-info:' added     'added:%a'        #  %a - Indicator to notify of added files.
zstyle ':git-info:' ahead     'ahead:%A'        #  %A - Indicator to notify of ahead branch.
zstyle ':git-info:' behind    'behind:%B'       #  %B - Indicator to notify of behind branch.
zstyle ':git-info:' branch    '%b'              #  %b - Branch name.
zstyle ':git-info:' clean     'clean'           #  %C - Indicator to notify of clean branch.
zstyle ':git-info:' commit    'commit:%c'       #  %c - SHA-1 hash.
zstyle ':git-info:' deleted   'deleted:%d'      #  %d - Indicator to notify of deleted files.
zstyle ':git-info:' dirty     'dirty'           #  %D - Indicator to notify of dirty branch.
zstyle ':git-info:' modified  'modified:%m'     #  %m - Indicator to notify of modified files.
zstyle ':git-info:' remote    '%R'              #  %R - Remote name.
zstyle ':git-info:' renamed   'renamed:%r'      #  %r - Indicator to notify of renamed files.
zstyle ':git-info:' stashed   'stashed:%S'      #  %S - Indicator to notify of stashed files.
zstyle ':git-info:' unmerged  'unmerged:%U'     #  %U - Indicator to notify of unmerged files.
zstyle ':git-info:' untracked 'untracked:%u'    #  %u - Indicator to notify of untracked files.
zstyle ':git-info:' prompt    'git:(%b%D%C)'    #  Left prompt.
zstyle ':git-info:' rprompt   ''                #  Right prompt.

# Gets the Git special action (am, merge, rebase, etc.).
# Borrowed from vcs_info and edited.
function _git-action() {
  local action=''
  local action_dir
  local git_dir="$(git-root)/.git"

  for action_dir in \
    "${git_dir}/rebase-apply" \
    "${git_dir}/rebase" \
    "${git_dir}/../.dotest"; do
    if [[ -d "$action_dir" ]] ; then
      if [[ -f "${action_dir}/rebasing" ]] ; then
        action='rebase'
      elif [[ -f "${action_dir}/applying" ]] ; then
        action='am'
      else
        action='am/rebase'
      fi
      echo "$action"
      return 0
    fi
  done

  for action_dir in \
    "${git_dir}/rebase-merge/interactive" \
    "${git_dir}/.dotest-merge/interactive"; do
    if [[ -f "$action_dir" ]]; then
      echo 'rebase-i'
      return 0
    fi
  done

  for action_dir in \
    "${git_dir}/rebase-merge" \
    "${git_dir}/.dotest-merge"; do
    if [[ -d "$action_dir" ]]; then
      echo 'rebase-m'
      return 0
    fi
  done

  if [[ -f "${git_dir}/MERGE_HEAD" ]]; then
    echo 'merge'
    return 0
  fi

  if [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]]; then
    echo 'cherry-pick'
    return 0
  fi

  if [[ -f "${git_dir}/BISECT_LOG" ]]; then
    echo 'bisect'
    return 0
  fi

  return 1
}

# Gets the Git status information.
function git-info() {
  # Extended globbing is needed to parse repository status.
  setopt local_options
  setopt extended_glob

  local action
  local action_format
  local action_formatted
  local added=0
  local added_format
  local added_formatted
  local ahead
  local ahead_format
  local ahead_formatted
  local ahead_or_behind
  local behind
  local behind_format
  local behind_formatted
  local branch
  local branch_info
  local branch_format
  local branch_formatted
  local clean
  local clean_formatted
  local commit
  local commit_short
  local commit_format
  local deleted=0
  local deleted_format
  local deleted_formatted
  local dirty
  local dirty_formatted
  local line_number=0
  local modified=0
  local modified_format
  local modified_formatted
  local remote
  local remote_format
  local remote_formatted
  local renamed=0
  local renamed_format
  local renamed_formatted
  local commit_formatted
  local stashed=0
  local stashed_format
  local stashed_formatted
  local unmerged=0
  local unmerged_format
  local unmerged_formatted
  local untracked=0
  local untracked_format
  local untracked_formatted
  local prompt
  local rprompt

  # Return if the directory is not a Git repository.
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != 'true' ]] \
    || [[ "$(git config --bool prompt.showinfo)" == "false" ]]; then
    unset git_prompt_info git_rprompt_info
    return 1
  else
    _git_info_executing='yes'

    # Get commit.
    commit="$(git rev-parse HEAD 2> /dev/null)"

    # Format commit (short).
    commit_short="$commit[1,7]"
    zstyle -s ':git-info:' commit commit_format
    zformat -f commit_formatted "$commit_format" "c:$commit_short"
  fi

  # Stashed
  if [[ -f "$(git-root)/.git/refs/stash" ]]; then
    stashed="$(git stash list 2>/dev/null | wc -l)"
    zstyle -s ':git-info:' stashed stashed_format
    zformat -f stashed_formatted "$stashed_format" "S:$stashed"
  fi

  # Assume that the working copy is clean.
  zstyle -s ':git-info:' clean clean_formatted

  while IFS=$'\n' read line; do
    (( line_number++ ))

    if (( line_number == 1)) && [[ "$line" == *'(no branch)'* ]]; then
      # Set branch to commit (short) when the branch is not found.
      branch="$commit_short"

      # Get action.
      action="$(_git-action)"
      if [[ -n "$action" ]]; then
        zstyle -s ':git-info:' action action_format
        zformat -f action_formatted "$action_format" "s:$action"
      fi
    elif (( line_number == 1 )) \
      && [[ "$line" == (#b)'## Initial commit on '(?##) ]]; then
      branch="$match[1]"
    elif (( line_number == 1 )); then
      # Split the line into an array for parsing.
      branch_info=(${(s: :)line})

      # Match: master...origin/master
      if [[ $branch_info[2] == (#b)(?##)...(?##/?##) ]]; then
        branch="$match[1]"
        remote="$match[2]"

        # Match: [ahead or [behind
        if [[ $branch_info[3] == (#b)\[(ahead|behind) ]]; then
          ahead_or_behind="$match[1]"
          if [[ "$ahead_or_behind" == 'behind' ]]; then
            # Extract digits: 10]
            behind="${branch_info[4]%\]}"
          else
            # Extract digits: 10] or 10,
            ahead="${branch_info[4]%[,\]]}"
            # Extract digits: 10]
            behind="${branch_info[6]%\]}"
          fi
        fi
      # Match: master
      elif [[ $branch_info[2] == (#b)(?##) ]]; then
        branch=$match[1]
      fi
    else
      # Format dirty.
      [[ -z "$dirty" ]] && zstyle -s ':git-info:' dirty dirty_formatted  && unset clean_formatted

      # Count: added/deleted/modified/renamed/unmerged/untracked
      [[ "$line" == (((A|M|D|T) )|(AD|AM|AT|MM))\ * ]] && (( added++ ))
      [[ "$line" == ( D|AD)\ * ]] && (( deleted++ ))
      [[ "$line" == (( (M|T))|(AM|AT|MM))\ * ]] && (( modified++ ))
      [[ "$line" == R\ \ * ]] && (( renamed++ ))
      [[ "$line" == UU\ * ]] && (( unmerged++ ))
      [[ "$line" == \?\?\ * ]] && (( untracked++ ))
    fi
  done < <(git status --short --branch 2> /dev/null)

  # Format branch.
  zstyle -s ':git-info:' branch branch_format
  zformat -f branch_formatted "$branch_format" "b:$branch"

  # Format remote.
  if [[ "$branch" != "$commit" ]]; then
    [[ -z $remote ]] \
      && remote=${$(git rev-parse --verify ${branch}@{upstream} \
      --symbolic-full-name 2> /dev/null)#refs/remotes/}
    zstyle -s ':git-info:' remote remote_format
    zformat -f remote_formatted "$remote_format" "R:$remote"
  fi

  # Format ahead.
  if [[ -n "$ahead" ]]; then
    zstyle -s ':git-info:' ahead ahead_format
    zformat -f ahead_formatted "$ahead_format" "A:$ahead"
  fi

  # Format behind.
  if [[ -n "$behind" ]]; then
    zstyle -s ':git-info:' behind behind_format
    zformat -f behind_formatted "$behind_format" "B:$behind"
  fi

  # Format added.
  if (( $added > 0 )); then
    zstyle -s ':git-info:' added added_format
    zformat -f added_formatted "$added_format" "a:$added_format"
  fi

  # Format deleted.
  if (( $deleted > 0 )); then
    zstyle -s ':git-info:' deleted deleted_format
    zformat -f deleted_formatted "$deleted_format" "d:$deleted_format"
  fi

  # Format modified.
  if (( $modified > 0 )); then
    zstyle -s ':git-info:' modified modified_format
    zformat -f modified_formatted "$modified_format" "m:$modified"
  fi

  # Format renamed.
  if (( $renamed > 0 )); then
    zstyle -s ':git-info:' renamed renamed_format
    zformat -f renamed_formatted "$renamed_format" "r:$renamed"
  fi

  # Format unmerged.
  if (( $unmerged > 0 )); then
    zstyle -s ':git-info:' unmerged unmerged_format
    zformat -f unmerged_formatted "$unmerged_format" "U:$unmerged"
  fi

  # Format untracked.
  if (( $untracked > 0 )); then
    zstyle -s ':git-info:' untracked untracked_format
    zformat -f untracked_formatted "$untracked_format" "u:$untracked"
  fi

  # Format prompts.
  zstyle -s ':git-info:' prompt prompt_format
  zstyle -s ':git-info:' rprompt rprompt_format

  typeset -A git_info_vars
  git_info_vars=(
    git_prompt_info "$prompt_format"
    git_rprompt_info "$rprompt_format"
  )

  for key in ${(k)git_info_vars}; do
    zformat -f $key $git_info_vars[$key] \
      "s:$action_formatted" \
      "a:$added_formatted" \
      "A:$ahead_formatted" \
      "B:$behind_formatted" \
      "b:$branch_formatted" \
      "C:$clean_formatted" \
      "c:$commit_formatted" \
      "d:$deleted_formatted" \
      "D:$dirty_formatted" \
      "m:$modified_formatted" \
      "R:$remote_formatted" \
      "r:$renamed_formatted" \
      "S:$stashed_formatted" \
      "U:$unmerged_formatted" \
      "u:$untracked_formatted"
  done

  _git_info_executing='no'
  return 0
}

# Thank you, Ashley Dev (https://github.com/ashleydev).
function _git-info-abort() {
  if ! check-bool "$_git_info_executing"; then
    return 1
  fi

  cat > /dev/stderr <<END

Git prompt status aborted.

Certain repositories take a long time to process.

To revert, execute:
  git config prompt.showinfo true

END

  git config prompt.showinfo 'false'
  return 0
}

# Called when CTRL-C is pressed.
function TRAPINT() {
  _git-info-abort
  return $(( 128 + $1 ))
}

