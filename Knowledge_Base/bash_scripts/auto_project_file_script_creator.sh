#This bash script automates the creation of a generic project folder used in every project

#I am doing this to fix my bash skils 
#Goal: Automate folder creation for a new project.

#Rules: Create a main folder from $1. Inside it, create 3 subfolders: src, docs, and bin. Inside src, create 5 empty files named file_1.txt through file_5.txt using a sequence.

#Psudocode
# 1. Take input on where the project directory is 
# 2. Validate , is this even a directory 
# 3. Validate , Can we write here ?
# 4. Create a folder in $1 location with the name 'main'
# 5. Then 3 subfiles 
# 6. In src, sequentially create file1 through 5 

#!/bin/bash
error_exit(){
    echo "$1" >&2
    exit "${2:-1}"
}

#Input on where the dir even is :

TARGET_DIR=$1

[[ -z "$1" ]] && error_exit "Usage: $0 <parent_diectory_path>" 1


[[ ! -d "$TARGET_DIR" ]] && error_exit "Error $DIR is not a directory"

PARENT_DIR=$(dirname "$TARGET_DIR")

[[ ! -d "$PARENT_DIR" ]] && error_exit "Parent directory $PARENT_DIR does not exist."
[[ ! -w "$PARENT_DIR" ]] && error_exit "Cannot write to $PARENT_DIR."

#Create folder 

mkdir -p $TARGET_DIR/{src,doc,bin }
touch $TARGET_DIR/src {1..5}.txt

echo "Done!"


