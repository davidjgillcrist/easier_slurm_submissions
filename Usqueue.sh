#!/bin/bash

Usqueue () {
    # Treat LC_TERMUX_QUERY as boolean: only literal "1" enables Termux mode
    local _tq="${LC_TERMUX_QUERY:-}"
    local _is_termux=0
    [[ "$_tq" == "1" ]] && _is_termux=1

    # Terminal width exactly as your original derives it
    local cols termw
    cols="$(tput cols 2>/dev/null || echo 0)"
    termw="${COLUMNS:-$cols}"
    termw=${termw:-120}

    # Choose AWK program
    local _base="$HOME/easier_slurm_submissions"
    local _awk="$_base/usqueue.awk"

    if (( _is_termux )); then
        # Orientation based on LC_TERMUX_WIDTH / LC_TERMUX_HEIGHT vs tput cols
        local _tw="${LC_TERMUX_WIDTH:-}"
        local _th="${LC_TERMUX_HEIGHT:-}"
        if [[ -n "$_tw" && "$cols" == "$_tw" ]]; then
            _awk="$_base/usqueue_TermuxPortrait.awk"
        elif [[ -n "$_th" && "$cols" == "$_th" ]]; then
            _awk="$_base/usqueue_TermuxLandscape.awk"
        else
            echo "Usqueue: warning: tput cols ($cols) matches neither LC_TERMUX_WIDTH (${_tw:-unset}) nor LC_TERMUX_HEIGHT (${_th:-unset}); defaulting to portrait." >&2
            _awk="$_base/usqueue_TermuxPortrait.awk"
        fi
    fi

    # EXACT original squeue format/order (STATE full %T), same sort and filter
    squeue -u "$USER" --noheader \
        --format='%i|%T|%j|%C|%m|%M|%l|%R' \
        --sort=+i \
    | awk -v termw="$termw" -v who="$USER" -f "$_awk"
}
