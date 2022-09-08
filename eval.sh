#!/usr/bin/env bash
Deval() {
    if [ $# -eq 0 ]; then
        >&2 echo "Must give an argument. 😉"
        return 0;
    fi
    local BASH_SETTINGS="$-"
    declare -gx __DEBUG_EVAL_SET
    : "${__DEBUG_EVAL_SET:=-xv}"
    set "$__DEBUG_EVAL_SET"
    # Runs the command. As safe as the original command :^)
    eval $@
    for setting in x v; do
        if [[ ! $setting =~ $BASH_SETTINGS ]]; then
            set "+$setting"
        fi
    done
}
