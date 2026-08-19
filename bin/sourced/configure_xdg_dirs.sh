## Setup XDG Desktop folder locations
#
# grscheller/bash-dotfiles uses these names in its setup scripts.
#
# - defaults to standard locations if not already defined
# - tries to ensures directories exist
# - failure to create will be indicated via stderr
#
# shellcheck shell=sh

# Script use XDG Desktop names, even on Windows 11

if test "$XDG_CONFIG_HOME" = ""
then
    _ensure_xdg_dirs_exist=no
else
    _ensure_xdg_dirs_exist=yes
fi

if test "$OS" = Windows_NT
then
    # Window 11
    _local_app_data="$(cygpath -u "$LOCALAPPDATA")"
    : "${XDG_CONFIG_HOME:=$_local_app_data}"
    : "${XDG_DATA_HOME:=$_local_app_data}"
    : "${XDG_STATE_HOME:=$_local_app_data}"
    : "${XDG_CACHE_HOME:=$_local_app_data/Temp}"
else
    # Linux
    _ensure_dirs_exist=yes
    : "${XDG_CONFIG_HOME:=$HOME/.config}"
    : "${XDG_DATA_HOME:=$HOME/.local/share}"
    : "${XDG_STATE_HOME:=$HOME/.local/state}"
    : "${XDG_CACHE_HOME:=$HOME/.cache}"
fi
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME

if test "_ensure_dirs_exist" = "yes"
then
    ensure_dir "$XDG_CONFIG_HOME" >&2
    chmod 0755 "$XDG_CONFIG_HOME"
    ensure_dir "$XDG_DATA_HOME" >&2
    chmod 0755 "$XDG_DATA_HOME"
    ensure_dir "$XDG_STATE_HOME" >&2
    chmod 0755 "$XDG_STATE_HOME"
    ensure_dir "$XDG_CACHE_HOME" >&2
    chmod 0755 "$XDG_CACHE_HOME"
fi

unset _ensure_dirs_exist
unset _local_app_data
