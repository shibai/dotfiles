# Git prompt and general helper methods

######################################
# These allow redefining the wrapping characters and having
# them included in the color changes
######################################

# What to display on either side of the git prompt
GIT_PROMPT_LEFT="["
GIT_PROMPT_RIGHT="]"

# What to display to indicate 
GIT_PROMPT_UNTRACKED="?"
GIT_PROMPT_DIRTY="*"

# Colors to use for different states
GIT_PROMPT_CLEAN_COLOR=green
GIT_PROMPT_DIRTY_COLOR=yellow
GIT_PROMPT_UNTRACKED_COLOR=red
GIT_PROMPT_DETACHED_COLOR=red
GIT_PROMPT_AHEAD_COLOR=yellow
GIT_PROMPT_BEHIND_COLOR=red

# How to mark different branch statuses
GIT_PROMPT_BEHIND="↑"
GIT_PROMPT_AHEAD="↓"
GIT_PROMPT_DIVERGED="↕"

# What to display to indicate a tracking branch
GIT_PROMPT_TRACKING="→"
GIT_PROMPT_MAX_TRACKING_NAME_LENGTH=50


function git_current_branch() {
    local ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo ${ref#refs/heads/}
}

function git_current_commit() {
    local commit=$(git rev-parse --short HEAD 2> /dev/null) || return
    echo $commit
}

function git_current_upstream_branch {
    local tracking=$(git rev-parse --abbrev-ref @{u} 2> /dev/null) || return
    echo ${tracking#'@{u}'}
    #local tracking=$(git for-each-ref --format='%(upstream)' refs/heads/$(git_current_branch))
    #if [[ $tracking =~ "refs/heads" ]]; then
    #    echo ${tracking#refs/heads/}
    #elif [[ $tracking =~ "refs/remotes/" ]]; then
    #    echo ${tracking#refs/remotes/}
    #else
    #    echo $tracking
    #fi
}

function git_current_repo_root() {
    local repo=$(git rev-parse --show-toplevel 2> /dev/null) || return
    echo $repo
}

function git_current_repo() {
    local repo=$(git_current_repo_root) || return
    echo ${repo##*/}
}

function git_current_repo_dir() {
    local dir=$(git rev-parse --show-prefix 2> /dev/null) || return
    echo ${dir%/}
}

function git_is_clean() {
    if [[ -n $(git status -s 2> /dev/null) ]]; then
        return 1
    else
        return 0
    fi
}

function git_has_tracked_changes() {
    if $(git status --porcelain &> /dev/null | grep '^[^?][^?] ' &> /dev/null); then
        return 0
    else
        return 1
    fi
}

function git_has_untracked_changes() {
    if $(git status --porcelain &> /dev/null | grep '^?? ' &> /dev/null); then
        return 0
    else
        return 1
    fi
}

function git_ahead_behind_prompt() {
    local prompt_color=$1;

    local -i ahead
    local -i behind
    ahead=0
    behind=0

    for commit in $(git rev-list --left-right @{u}...HEAD 2> /dev/null); do
        if [[ $commit =~ "^>" ]]; then
            (( ahead++ ))
        elif [[ $commit =~ "^<" ]]; then
            (( behind++ ))
        fi
    done

    local ahead_color=$fg[$GIT_PROMPT_AHEAD_COLOR]
    local behind_color=$fg[$GIT_PROMPT_BEHIND_COLOR]

    if [[ $ahead > 0 && $behind == 0 ]]; then
        echo "%{$ahead_color%}$ahead$GIT_PROMPT_AHEAD%{$prompt_color%}"
    elif [[ $ahead == 0 && $behind > 0 ]]; then
        echo "%{$behind_color%}$GIT_PROMPT_BEHIND$behind%{$prompt_color%}"
    elif [[ $ahead > 0 && $behind > 0 ]]; then
        echo -n "%{$ahead_color%}$ahead%{$prompt_color%}$GIT_PROMPT_DIVERGED"
        echo "%{$behind_color%}$behind%{$prompt_color%}"
    else
    fi
}

function git_branch_prompt() {
    local clean_color=$fg[$GIT_PROMPT_CLEAN_COLOR]
    local dirty_color=$fg[$GIT_PROMPT_DIRTY_COLOR]
    local untracked_color=$fg[$GIT_PROMPT_UNTRACKED_COLOR]
    local detached_color=$fg[$GIT_PROMPT_DETACHED_COLOR]

    local branch=$(git_current_branch)
    if [[ -z $branch ]]; then
        local commit=$(git_current_commit)
        if [[ -n $commit ]]; then
            echo -n "%{$detached_color%}%B"
            echo -n $GIT_PROMPT_LEFT
            echo -n $commit
            echo -n $GIT_PROMPT_RIGHT
            echo "%b%{$reset_color%}"
        fi
        return
    fi

    local tracking=$(git_current_upstream_branch)
    if [[ ${#tracking} -ge $GIT_PROMPT_MAX_TRACKING_NAME_LENGTH ]] ; then
        tracking=$(echo $tracking | sed "s/\(.\{$GIT_PROMPT_MAX_TRACKING_NAME_LENGTH\}\).*/\1.../")
    fi

    local prompt_color;
    if git_is_clean; then
        prompt_color=$clean_color
    else
        prompt_color=$dirty_color
    fi
    echo -n "%{$prompt_color%}%B"

    echo -n $GIT_PROMPT_LEFT
    if git_has_tracked_changes ; then
        echo -n $GIT_PROMPT_DIRTY
    fi
    if git_has_untracked_changes; then
        echo -n "%{$untracked_color%}"
        echo -n "$GIT_PROMPT_UNTRACKED"
        echo -n "%{$prompt_color%}"
    fi

    if ! git_is_clean; then echo -n " "; fi
    echo -n $branch

    if [[ -n $tracking ]]; then
        echo -n "$GIT_PROMPT_TRACKING$tracking"
    fi

    local tree=$(git_ahead_behind_prompt $prompt_color)
    if [[ -n $tree ]]; then
        echo -n " $tree"
    fi

    echo -n $GIT_PROMPT_RIGHT
    echo "%b%{$reset_color%}"
}

function git_chpwd() {
    export GIT_CURRENT_BRANCH=${git_current_branch}
}

chpwd_functions=(${chpwd_functions[@]} "git_chpwd")
