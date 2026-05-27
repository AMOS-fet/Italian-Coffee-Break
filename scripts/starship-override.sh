#!/bin/bash
# -----------------------------------------------------
# File: starship-override.sh
# Description: Starship theme local override
# -----------------------------------------------------

MODE=$1
DOTFILES="$HOME/dotfiles"
STARSHIP_DIR="$DOTFILES/starship/.config"

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
    echo "Errore: Specifica la modalità [dark|light]"
    exit 1
fi

BASE_FILE="$STARSHIP_DIR/starship-${MODE}.toml"
LOCAL_FILE="$STARSHIP_DIR/starship-local.toml"
OVERRIDE_FILE="$STARSHIP_DIR/starship-local-override.toml"

rm -f "$OVERRIDE_FILE"

cp "$BASE_FILE" "$OVERRIDE_FILE"

if [[ -f "$LOCAL_FILE" ]]; then
    
    awk -v local_file="$LOCAL_FILE" '
    BEGIN {
        sec = "";
        while ((getline < local_file) > 0) {
            if ($0 ~ /^[ \t]*\[.*\]/) {
                sec = $0;
                sub(/^[ \t]*\[/, "", sec); sub(/\][ \t]*$/, "", sec);
                gsub(/^[ \t]+|[ \t]+$/, "", sec);
            } else if ($0 ~ /=/) {
                idx = index($0, "=");
                k = substr($0, 1, idx-1);
                v = substr($0, idx+1);
                gsub(/^[ \t]+|[ \t]+$/, "", k);
                overrides[sec "\034" k] = v;
            }
        }
        close(local_file);
        current_sec = "";
        first_sec_found = 0;
    }
    {
        if ($0 ~ /^[ \t]*\[.*\]/) {
            if (first_sec_found == 0) {
                first_sec_found = 1;
                # Inietta le variabili globali (prima della prima sezione)
                for (comb in overrides) {
                    split(comb, arr, "\034");
                    if (arr[1] == "") {
                        print arr[2] " =" overrides[comb];
                        delete overrides[comb];
                    }
                }
            } else if (current_sec != "") {
                # Inietta chiavi nuove per la sezione appena conclusa
                for (comb in overrides) {
                    split(comb, arr, "\034");
                    if (arr[1] == current_sec) {
                        print arr[2] " =" overrides[comb];
                        delete overrides[comb];
                    }
                }
            }
            
            current_sec = $0;
            sub(/^[ \t]*\[/, "", current_sec); sub(/\][ \t]*$/, "", current_sec);
            gsub(/^[ \t]+|[ \t]+$/, "", current_sec);
            printed_secs[current_sec] = 1;
            print $0;
            
        } else if ($0 ~ /=/) {
            idx = index($0, "=");
            k = substr($0, 1, idx-1);
            gsub(/^[ \t]+|[ \t]+$/, "", k);
            
            if ((current_sec "\034" k) in overrides) {
                print k " =" overrides[current_sec "\034" k];
                delete overrides[current_sec "\034" k];
            } else {
                print $0;
            }
        } else {
            print $0;
        }
    }
    END {
        if (current_sec != "") {
            for (comb in overrides) {
                split(comb, arr, "\034");
                if (arr[1] == current_sec) {
                    print arr[2] " =" overrides[comb];
                    delete overrides[comb];
                }
            }
        }
        for (comb in overrides) {
            split(comb, arr, "\034");
            s = arr[1]; k = arr[2];
            if (s == "") {
                print k " =" overrides[comb];
            } else {
                if (!(s in printed_secs)) {
                    print "\n[" s "]";
                    printed_secs[s] = 1;
                }
                print k " =" overrides[comb];
            }
        }
    }
    ' "$BASE_FILE" > "$OVERRIDE_FILE.tmp"
    
    mv "$OVERRIDE_FILE.tmp" "$OVERRIDE_FILE"
fi
