# Bash Syntax — Personal Reference

## read with prompt
read -p "message: " VARIABLE     # -p required for prompt

## while loop reading a file
while IFS=, read -r col1 col2; do
    # body
done < "$FILE"                    # redirect at the done, not the while

## if/elif/fi structure
if [ condition ]; then
    # body
elif [ condition ]; then
    # body
else
    # body
fi                                # always close with fi

## quoting rules
"$VAR"     # double quotes: expands variables
'$VAR'     # single quotes: literal, NO expansion
$(command) # command substitution

## paths
~/folder/file    # Linux: forward slashes always