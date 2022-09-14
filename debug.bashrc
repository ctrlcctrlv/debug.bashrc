#!/usr/bin/env bash
# This can't go in debugsh_init as we don't want invalid syntax to be read if it can be helped.
if test "`basename $SHELL`" != "bash"; then
    >&2 echo "Using $SHELL, not Bash, dying!"
    exit 1
fi
syntaxhighlight_vimpager () {
    ARG=`printf "%q" "$1"`;
    script -E never -q -c "tee|vimpager --force-passthrough -c 'set syntax=$ARG' -c 'setf $ARG'";
}
syntaxhighlight_pygmentize() {
    tee | pygmentize -l "$1";
}
syntaxhighlighter() {
    shopt -s nocasematch
    __d_return() {
        shopt -u nocasematch;
        unset __d_return; # Yes this is valid.
    }
    case "$1" in
        pygmentize)
            function syntaxhighlight() {
                syntaxhighlight_pygmentize "$@";
            }
        ;;
        vimpager)
            function syntaxhighlight() {
                syntaxhighlight_vimpager "$@";
            }
        ;;
        *)
            syntaxhighlighter pygmentize;
            >&2 echo "Unrecognized highlighter!: $1";
            __d_return
        ;;
    esac
    case "$1" in
        pygmentize|vimpager) echo "Syntax highlighter now $1"
        ;;
    esac
    declare -gfx syntaxhighlight
    declare -gx BASH_SYNTAXHIGHLIGHTER_BINREQ="$1"
    __d_return
    return 0
}
print_bash_function () { 
    type "$1" | tail -n +2;
}
list_all_bash_functions() {
    declare -pF | awk '{if ('"`[ ! -z "$1" ] && printf '%s' ' ( $3 !~ '"$1"' ) ' || echo '1'`"') { print $3 }}';
}
print_all_bash_functions() {
    HIGHLIGHT_CMD="list_all_bash_functions "`printf '%q' "$1"`" | while read line; do print_bash_function \$line | syntaxhighlight bash; done"
    [ ! -z "$2" ] && (eval $HIGHLIGHT_CMD | aha $AHA_BASH_PRINT_ARGS > "$2") || (>&2 eval $HIGHLIGHT_CMD)
}

debugsh_init() {
    debugsh_init_plugins
    if [ ! -z "$NO_CCCV_DEBUG_BASHRC" ]; then
        return 2
    fi
    local color_prompt
    case "$TERM" in
        xterm-*|*-{true,256}color) color_prompt="y";;
    esac
    if [ ! -z "$BASH_SYNTAXHIGHLIGHTER_BINREQ" ]; then
        syntaxhighlighter "$BASH_SYNTAXHIGHLIGHTER_BINREQ"
    elif hash pygmentize; then
        syntaxhighlighter pygmentize
    elif hash vimpager; then
        syntaxhighlighter vimpager
    fi > /dev/null
    if [ ! -z $BASH_SYNTAXHIGHLIGHTER_BINREQ ]; then
        echo "default syntax highlighter: $BASH_SYNTAXHIGHLIGHTER_BINREQ"
        return 0
    else
        >&2 echo "no syntaxhighlighter loaded"
        return 1
    fi
    return 0
}
debugsh_init_plugins() {
    local __DEBUG_DIRNAME=$(dirname -- "${BASH_SOURCE[0]}")
    local __PLUGINS=$(find "$__DEBUG_DIRNAME" -iregex '.*\.\(sh\|bashrc\)' -and -not -name 'debug.bashrc' -type f)
    for plugin in $__PLUGINS; do
        plugin=$(readlink -f "$plugin")
        readlink -f "$plugin" > /dev/null && source "$plugin"
    done
}

declare -gx AHA_BASH_PRINT_ARGS='--black'

debugsh_init && declare -gfx syntaxhighlight
