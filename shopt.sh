#!/usr/bin/env bash
Ddiffshopt() {
    >&2 echo Recall: Additions are changes from default to current subshell. \
        $'\n\t'Lines with no red words for context only.$'\n'
    local WD
    WD=$(wdiff <(NO_CCCV_DEBUG_BASHRC=y bash -i -c 'shopt -p' 2> /dev/null) <(shopt -p))
    grep -C 2 '\[-.*-\]\|\{+.*+\}' <<< """$WD"""
    return 0
}
