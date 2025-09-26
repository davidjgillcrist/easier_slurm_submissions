#!/bin/bash

Usqueue() {
  local termw="${COLUMNS:-$(tput cols 2>/dev/null)}"
  termw=${termw:-120}

  # raw, untruncated fields separated by |
  local raw
  raw="$(squeue -u "$USER" --noheader \
          --format='%i|%T|%j|%C|%m|%M|%l|%R' --sort=+i)"

  echo "$raw" | awk -v termw="$termw" -v who="$USER" -f $HOME/easier_slurm_submissions/usqueue.awk
}

