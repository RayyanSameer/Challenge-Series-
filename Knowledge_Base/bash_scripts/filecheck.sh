if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi


if [ -f "$1" ]; then
    echo "Size: $(du -h "$1" | cut -f1)"
    echo "Modified: $(stat -c %y "$1")"
else
    echo "Error: file '$1' not found"
    exit 1
fi