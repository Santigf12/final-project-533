#!/bin/bash

# Temp file to hold the Glances output
LOGFILE=$(mktemp)

# Function to clean up on exit
cleanup() {
    echo -e "\n\nCalculating averages..."
    awk -F'[:|]' '
    {
        cpu += $2;
        mem += $4;
        swap += $6;
        load += $8;
        n++
    }
    END {
        print "📊 Averages over runtime:";
        print "-------------------------";
        printf "🧠 Avg RAM usage:     %.2f%%\n", mem/n;
        printf "💽 Avg Swap usage:    %.2f%%\n", swap/n;
        printf "🖥️  Avg CPU usage:     %.2f%%\n", 100 - (cpu/n);
        printf "📈 Avg Load Average:  %.2f\n", load/n;
    }' "$LOGFILE"
    rm -f "$LOGFILE"
    exit
}

# Trap Ctrl+C to stop cleanly
trap cleanup INT

# Start glances
echo "Recording system stats... Press Ctrl+C to stop."
glances --stdout cpu.idle,mem.used_percent,swap.used_percent,load -t 5 > "$LOGFILE"
