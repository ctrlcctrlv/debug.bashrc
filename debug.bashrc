#!/usr/bin/env bash
debugsh_init() {
    ( (hash pygmentize && syntaxhighlighter pygmentize) 2> /dev/null;
      (hash vimpager && syntaxhighlighter vimpager) 2> /dev/null )
    >&2 echo == debug.sh loaded ==;
    [ ! -z "$BASH_SYNTAXHIGHLIGHTER_BINREQ" ] && >&2 echo "default syntax highlighter: $BASH_SYNTAXHIGHLIGHTER_BINREQ"
}
syntaxhighlight_vimpager () {
    ARG=`printf "%q" "$1"`;
    script -E never -q -c "tee|vimpager --force-passthrough -c 'set syntax=$ARG' -c 'setf $ARG'";
}
syntaxhighlight_pygmentize() {
    tee | pygmentize -l "$1";
}
syntaxhighlighter() {
    [ $(declare -fF syntaxhighlight) ] && unset syntaxhighlight;
    shopt -s nocasematch
    export BASH_SYNTAXHIGHLIGHTER_BINREQ="$1"
    function __d_return() {
        shopt -u nocasematch;
        unset __d_return; # Yes this is valid.
    }
    case "$1" in
        pygmentize)
            syntaxhighlight() {
                syntaxhighlight_pygmentize "$@";
            };
        ;;
        vimpager)
            syntaxhighlight() {
                syntaxhighlight_vimpager "$@";
            };
        ;;
        *)
            syntaxhighlighter pygmentize;
            >&2 echo "Unrecognized highlighter!: $1";
            __d_return
        ;;
    esac
    case "$1" in
        pygmentize|vimpager) >&2 echo "Syntax highlighter now $1"
        ;;
    esac
    __d_return
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

export AHA_BASH_PRINT_ARGS='--black';

debugsh_init;
