#!/usr/bin/env bash
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

export AHA_BASH_PRINT_ARGS='--black'

debugsh_init && declare -gfx syntaxhighlight
