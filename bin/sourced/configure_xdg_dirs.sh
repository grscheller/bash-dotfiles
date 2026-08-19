## Setup XDG Desktop folder locations
#
# grscheller/dotfiles uses these names in its setup scripts.
#
# - defaults to standard locations if not already defined
# - tries to ensures directories exist
# - failure to create will be indicated via stderr
#
# shellcheck shell=sh

# Script exclusively use these names
if test "$OS" = Windows_NT
then
    _local_app_data="$(cygpath -u "$LOCALAPPDATA")"
    : "${XDG_CONFIG_HOME:=$_local_app_data}"
    : "${XDG_DATA_HOME:=$_local_app_data}"
    : "${XDG_STATE_HOME:=$_local_app_data}"
    : "${XDG_CACHE_HOME:=$_local_app_data/Temp}"
    unset _local_app_data
else
    # Can be overridden for multiple configurations
    : "${XDG_CONFIG_HOME:=$HOME/.config}"
    : "${XDG_DATA_HOME:=$HOME/.local/share}"
    : "${XDG_STATE_HOME:=$HOME/.local/state}"
    : "${XDG_CACHE_HOME:=$HOME/.cache}"
fi
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME

# Ensure these folder exists before installation.
ensure_dir "$XDG_CONFIG_HOME" >&2
chmod 0755 "$XDG_CONFIG_HOME"
ensure_dir "$XDG_DATA_HOME" >&2
chmod 0755 "$XDG_DATA_HOME"
ensure_dir "$XDG_STATE_HOME" >&2
chmod 0755 "$XDG_STATE_HOME"
ensure_dir "$XDG_CACHE_HOME" >&2
chmod 0755 "$XDG_CACHE_HOME"
