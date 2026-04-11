1. The Argument Gatekeeper

Never start a script without ensuring you have the right "ingredients."

# Check for exactly 2 arguments
[[ $# -ne 2 ]] && { echo "Usage: $0 <input_file> <output_dir>"; exit 1; }

2. The "Bulletproof" File Check

# Always verify your targets exist before the "verb" (mv, cp, rm).

[[ ! -f "$1" ]] && { echo "Error: File $1 not found."; exit 1; }
[[ ! -d "$2" ]] && mkdir -p "$2"

3. The Modern Loop (The "Streamer")

# This is the safest way to read files without mangling whitespace.

while IFS= read -r line; do
    # Do something with "$line"
    echo "Processing: $line"
done < "$INPUT_FILE"

4. The Smart Filter (Grep)

Use flags to make it powerful. -E for regex, -i for case-insensitive, -q for silent checks.

if grep -qEi "error|fail|critical" "$LOG_FILE"; then
    echo "Issues found!"
fi

5. The Clean Exit (Error Handling)

Put this at the top of your scripts to stop immediately if any command fails.


set -euo pipefail
# e: exit on error | u: exit on unset variables | o pipefail: catch errors in pipes

DevHints.io/Bash: The ultimate one-page cheatsheet. Keep this tab open 24/7.

ShellCheck.net: The "Mentor in the Machine." Paste your code here; it will find the missing spaces for you.

LinuxJourney.com: Go to the "Bash Scripting" section. It's bite-sized and perfect for when you're tired.

Explainshell.com: Paste a complex command (like an awk string) and it breaks down exactly what every flag does.