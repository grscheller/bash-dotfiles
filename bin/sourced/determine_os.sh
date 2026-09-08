# shellcheck shell=sh

# Determine OS dotfiles are being installed
case $(uname -s) in
    MSYS* | MINGW* | CYGWIN*)
        OS_GRS=windows
        ;;
    Linux)
        if test -r /etc/os-release
        then
            _os_ids=$(. /etc/os-release; printf ' %s %s ' "$ID" "$ID_LIKE")
            . /etc/os-release
            case "$_os_ids" in
                *' debian '*)
                    OS_GRS=linux_debian
                    ;;
                *' rhel '* | *' fedora '*)
                    OS_GRS=linux_redhat_untested
                    ;;
                *)
                    OS_GRS=linux_unknown_unsupported
                    ;;
            esac
        else
            OS_GRS=linux_unsupported
        fi
        ;;
    Darwin)
        OS_GRS=darwin_unsupported
        ;;
    FreeBSD)
        OS_GRS=freebsd_unsupported
        ;;
    OpenBSD)
        OS_GRS=openbsd_unsupported
        ;;
    NetBSD)
        OS_GRS=netbsd_unsupported
        ;;
    DragonFly)
        OS_GRS=dragonflybsd_unsupported
        ;;
    *)
        OS_GRS=unknown_unsupported
        ;;
esac
export OS_GRS
unset _os_ids
