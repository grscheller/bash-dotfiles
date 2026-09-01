# shellcheck shell=bash
#
# Bash configuration with a strong ksh flavor
# aimed at modern Systemd based Linux systems.
#
# Primarily as a fallback when fish is unavailable.
#

### First part for both interactive & non-interactive shells.

## Non-GUI related Shell functions

#  Jump up multiple directories
function ud {
    if (($# > 1))
    then
        printf 'Error: ud takes 0 or 1 arguments\n\n'
        return 1
    elif (($# == 0)) || [[ -z $1 ]]
    then
        cd ..
        return $?
    fi

    local ifs_old="$IFS"
    IFS='/'

    local max_up=-1
    local Dir
    for Dir in $PWD
    do
        ((maxUp++))
    done

    IFS="$ifs_old"

    local up=..
    local num_dirs
    local cnt=0
    local target="$1"

    # user gave a number > 0
    if [[ $target == @([1-9])*([0-9]) ]]
    then
        if ((target < max_up))
        then
            ((num_dirs = target))
        else
            ((num_dirs = max_up))
        fi
        until ((num_dirs-- <= 1))
        do
            up=../$up
        done
        cd $up || return 0
        return 1
    fi

    # user gave a target to find
    # First look for exact match
    while ((cnt < max_up))
    do
        if [[ -e $up/$target ]]
        then
            if [[ -d $up/$target ]]
            then
                cd "$up/$target" || return 1
            else
                cd "$up" || return 1
            fi
            return 0
        fi
        up=../$up
        ((cnt++))
    done

    # Otherwise, find an initial string match
    cnt=0
    up=..
    local target_start="$1"
    local first
    shopt -s nullglob
    while ((cnt < max_up))
    do
        for first in "$up"/"$target_start"*
        do
            if [[ -d $first ]]
            then
                cd "$first" || {
                    shopt -u nullglob
                    return 1
                }
            else
                cd "$up" || {
                    shopt -u nullglob
                    return 1
                }
            fi
            shopt -u nullglob
            return 0
        done
        up=../$up
        ((cnt++))
    done
    printf 'ud: "%s" not found in any higher directory\n\n' "$target"
    shopt -u nullglob
    return 2
}

# Similar to the DOS path command
function pa {
    local path_word
    if (($# == 0))
    then
        path_word="$PATH"
    else
        path_word="$1"
    fi

    # shellcheck disable=SC2086
    (
        IFS=':'
        printf '%s\n' $path_word
    )
}

# remove duplicates and standardize $PATH components
function pathtrim {
    if [[ $# -ne 1 ]]
    then
        printf 'Error: pathtrim takes exactly one argument\n\n'
        return 1
    fi
    local path_raw="$1"

    # Sed script to standardize the $PATH list:
    # - remove redundant / and :
    # - remove trailing /'s on directory names
    # - replace /./ -> /
    # - escape tabs, spaces, and parentheses
    local sed_script="s!/+!/!g
                      s!:+!:!g
                      s!([^:])/:!\1:!g
                      s!/\./!/!g
                      s!:\./!:!g
                      s! !\\ !g
                      s!	!\\	!g
                      s!\(!\\(!g
                      s!\)!\\)!g
                      s!^:!!"
    local path_normalized Dir add_to_path_flag
    local -a dirs_canonicalized=()

    path_normalized="$(printf %s "$path_raw" | sed -E -e "$sed_script")"

    local ifs_old="$IFS"
    IFS=':'

    for Dir in $path_normalized
    do
        if [[ -d $Dir ]]
        then
            Dir="$(readlink --canonicalize-existing "$Dir")"
        else
            continue
        fi

        local nn=0
        add_to_path_flag=
        while ((nn < ${#dirs_canonicalized[@]}))
        do
            if [[ $Dir == "${dirs_canonicalized[$nn]}" ]]
            then
                unset add_to_path_flag
                break
            fi
            ((nn++))
        done

        if [[ -v add_to_path_flag ]]
        then
            dirs_canonicalized[nn]="$Dir"
        fi
    done

    IFS="$ifs_old"

    local path_trimmed=
    for Dir in "${dirs_canonicalized[@]}"
    do
        if test -n "$path_trimmed"
        then
            path_trimmed="$path_trimmed:$Dir"
        else
            path_trimmed=$Dir
        fi
    done
    printf '%s\n' "${path_trimmed}"

    return 0
}

# Drill down through $PATH to look for files or directories.
# Like the ksh builtin whence, except it does not stop
# after finding the first instance. Handles spaces in both
# filenames and directories on $PATH. Also, shell patterns
# are supported.
function digpath {
    local OPTIND opt
    local quiet_flag=
    local executable_flag=0
    while getopts :qx opt
    do
        case $opt in
        q) quiet_flag=1 ;;
        x) executable_flag=1 ;;
        *) local msg="usage: digpath [-q] [-x] 'glob1' ['glob2' 'glob3' ...]"
           printf '%s\n' "$msg"
           return 2 ;;
        esac
    done

    local Dir File Target
    local -a file_list=()
    local ii=0

    local ifs_old="$IFS"
    IFS=':'

    for File in "$@"
    do
        [[ -z $File ]] && continue
        for Dir in $PATH
        do
            [[ ! -d $Dir ]] && continue
            for Target in $Dir/$File
            do
                if [[ -e $Target ]] || [[ -L $Target ]]
                then
                    if ((executable_flag == 0)) || [[ -x $Target ]]
                    then
                        file_list[ii++]="$Target"
                    fi
                fi
            done
        done
    done

    IFS="$ifs_old"

    [[ -z $quiet_flag ]] && printf '%s\n' "${file_list[@]}"

    if ((${#file_list[@]} > 0))
    then
        return 0
    else
        return 1
    fi
}

# Archive eXtractor: usage: ax <file>
function ax {
    if [[ -f $1 ]]
    then
        case $1 in
        *.tar) tar -xvf "$1" ;;
        *.tar.bz2) tar -xjvf "$1" ;;
        *.tbz2) tar -xjvf "$1" ;;
        *.tar.gz) tar -xzvf "$1" ;;
        *.tgz) tar -xzvf "$1" ;;
        *.tar.Z) tar -xZvf "$1" ;;
        *.gz) gunzip "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.rar) unrar x "$1" ;;
        *.tar.xz) xz -dc "$1" | tar -xvf - ;;
        *.tar.7z) 7za x -so "$1" | tar -xvf - ;;
        *.7z) 7z x "$1" ;;
        *.tar.zst) zstd -dc "$1" | tar -xvf - ;;
        *.zst) zstd -d "$1" ;;
        *.cpio) cpio -idv <"$1" ;;
        *) printf 'ax: error: "%s" unknown file type' "$1" >&2 ;;
        esac
    else
        if [[ -n $1 ]]
        then
            printf 'ax: error: "%s" is not a file' "$1" >&2
        else
            printf 'ax: error: No file argument given' >&2
        fi
    fi
}

### For non-interactive shells, omit the rest.
[[ $- != *i* ]] && return

#  Open Desktop file manager
function fm {
    local Dir="$1"
    [[ -n $Dir ]] || Dir="$PWD"
    xdg-open "$Dir" 2>/dev/null &
}

# Terminal which inherits environment of parent shell
function tm {
    if [[ -x /usr/bin/cosmic-term ]]
    then
        (/usr/bin/cosmic-term &)
    elif [[ -x /usr/bin/alacritty ]]
    then
        (/usr/bin/alacritty &)
    elif [[ -x /usr/bin/gnome-terminal ]]
    then
        (/usr/bin/gnome-terminal >/dev/null 2>&1 &)
    elif [[ -x /usr/bin/xterm ]]
    then
        (/usr/bin/xterm >/dev/null 2>&1 &)
    else
        printf "error: no terminal emulator found\n" >&2
    fi
}

#  PDF Reader
function ev {
    (/usr/bin/evince "$@" >/dev/null 2>&1 &)
}

# Firefox Browser
function ff {
    if digpath -q firefox
    then
        (firefox "$@" >&- 2>&- &)
    else
        printf 'firefox not found\n' >&2
    fi
}

## Aliases

alias nv=nvim
alias pst='ps -ejH'

# ls alias family
alias ls='ls --color=auto'
alias la='ls -a'
alias lh='ls -lh'
alias ll='ls -ltr'
alias l.='ls -dA .*' # for current directory only

# single quotes below intentional
alias bI='$BASH_DOTFILE_GIT_REPO/bin/bashInstall'
alias fI='$FISH_DOTFILE_GIT_REPO/bin/fishInstall'
alias mI='$MISC_DOTFILE_GIT_REPO/bin/miscInstall'
alias nI='$NVIM_DOTFILE_GIT_REPO/bin/nvimInstall'

# Website scrapping - pull down a subset of a website
alias Wget='/usr/bin/wget -p --convert-links -e robots=off'
# Pull down more -- Not good for large websites
alias WgetM='/usr/bin/wget --mirror -p --convert-links -e robots=off'

alias ga='git add'
alias gb='git branch'
alias gbl='git branch --list|cat'
alias gc='git commit -S'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gh='git push'
alias gl='git log'
alias gm='git mv'
alias gp='git pull'
alias gs='git status'
alias gsu='git submodule update'
alias gsm='git submodule update --remote --merge'
alias gt='git tag --list|cat'
alias gw='git switch'

alias dp='digpath'

## Make Bash more Korn Shell like

set -o pipefail
shopt -s extglob
shopt -s checkwinsize
shopt -s checkhash
shopt -s cmdhist
shopt -s lithist
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=5000
HISTFILESIZE=5000
HISTCONTROL=ignoredups

## Prompt and window decorations

# get hostnames
TERM_USER="$(id -un)@$(hostname)"

# Terminal window title prompt string
case $TERM in
alacritty | cosmic-term | gnome* | xterm*)
    TERM_TITLE=$'\e]0;'"${TERM_USER}"$'\007'
    ;;
*)
    TERM_TITLE=''
    ;;
esac

# Setup up 3 line prompt
PS1="[$TERM_USER: \w]\n\$ ${TERM_TITLE}"
PS2='> '
PS4='+ ${BASH_SOURCE}:${LINENO}: '
