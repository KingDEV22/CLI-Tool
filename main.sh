#!/bin/bash

#Constants
functions=('Files Manipulation' 'News' 'Weather' 'Sports')
groups=("Owner" "Group" "Others")
dir_operation=('Create Directory' 'Delete Directory' 'Update Directory Name' 'Check Permissions' 'Edit Permissions' 'File Operations' 'Organizer')
files_operation=('Create File' 'Delete File' 'Write/Edit File' 'Update FileName' 'Edit Permissions' 'File Info' 'Read File')

#Print the element of any array
print_array() {
    local array=("$@")
    for e in "${!array[@]}"; do
        echo "$((e + 1)). ${array[$e]}"
    done
}

# Read any value from the terminal
read_value() {
    read -r -p"Enter the option, Press E to exit, M for Previous Menu: " value
    echo "$value"
}

# Update the permissions of any file or directory
edit_permissions() {
    local permissions=("Read" "Write" "Execute")
    local bit_value=(4 2 1)
    local permission=""

    for e in "${!groups[@]}"; do
        t=0
        for i in "${!permissions[@]}"; do
            read -r -p "Do you need ${permissions[$i]} permission for ${groups[$e]}? (Y/N): " per
            x=$(if [[ "$per" == "Y" || "$per" == "y" ]]; then echo "${bit_value[$i]}"; else echo 0; fi)
            t=$((t + x))
        done
        permission+="$t"
    done

    echo "$permission"
}

# Return the permission of a file or directory
file_or_directory_permission() {
    local permission=$1
    char="${permission:0:1}"
    if [[ "$char" == "-" ]]; then
        echo -e "$(get_file_or_direactory_symbol "$2") \xE2\x86\x92 Regular file"
    elif [[ "$char" == "d" ]]; then
        echo -e "$(get_file_or_direactory_symbol "$2") \xE2\x86\x92 Regular Directory"
    elif [[ "$char" == 'l' ]]; then
        echo -e "$(get_file_or_direactory_symbol "$2") \xE2\x86\x92 Symbolic Links"
    fi
    x=0
    echo "Permissions: "
    for ((i = 1; i < ${#permission}; i += 3)); do
        char="${permission:i:3}"
        info="${groups[$x]}: "
        for ((j = 0; j < ${#char}; j++)); do
            c="${char:j:1}"
            case $c in
            "r")
                info+="Read (r) "
                ;;
            "w")
                info+="Write (w) "
                ;;
            "x")
                info+="Execute (x) "
                ;;
            esac
        done
        x=$((x + 1))
        echo "$info"
    done
}

make_dir_move_files() {
    local file dir newpath
    file=$1
    dir=$2
    mkdir -p "$dir"
    newpath="$dir/$file"
    mv "$file" "$newpath"
}

# Organize files and directories
dir_organizer() {
    local dir
    dir=$(pwd)

    declare -A extensions=(
        [mp3]="music"
        [wav]="music"
        [aac]="music"
        [aiff]="music"
        [jpg]="picture"
        [png]="picture"
        [gif]="picture"
        [jpeg]="picture"
        [mp4]="videos"
        [mkv]="videos"
        [mov]="videos"
        [avi]="videos"
        [wmv]="videos"
        [flv]="videos"
        [py]="python"
        [java]="java"
        [class]="java"
        [sh]="bash"
        [rs]="rust"
        [txt]="text file"
        [docs]="document"
        [doc]="document"
        [docx]="document"
        [odf]="document"
        [ppt]="presentation"
        [pdf]="Pdf files"
    )

    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            name=${file##*/} # Extract filename without directory path
            extension=${name##*.}
            if [[ -n "${extensions[$extension]}" ]]; then
                make_dir_move_files "$name" "${extensions[$extension]}"
            else
                echo "File ignored: $name" # Print ignored file names for unknown extensions
            fi
        fi
    done
}

# Return the file or directory symbol
get_file_or_direactory_symbol() {
    local name=$1
    file=""
    if [ -f "$name" ]; then
        name="$(basename "$name")"
        extension="${name##*.}"
        case $extension in
        "mp3" | "wav" | "aac" | "aiff")
            file+="-→ 🎵 $name" # Text file icon
            ;;
        "jpg" | "png" | "gif" | "jpeg")
            file+="-→ 🖼️ $name" # Image file icon
            ;;
        "mp4" | "mkv" | "mov" | "avi" | "wmv" | "flv")
            file+="-→ 📽️ $name"
            ;;
        *)
            file+="-→ 📄 $name" # Default folder icon for unknown extensions
            ;;
        esac
    elif [ -d "$name" ]; then
        name="$(basename "$name")"
        file+="-→ 📂 $name"
    fi
    echo "$file"
}

#list all files and directory inside a directory
list_directory() {
    dir=$1
    echo "$(get_file_or_direactory_symbol $dir)"
    local files
    if [[ $2 == '0' ]]; then
        files=("$dir"/*)
    else
        mapfile -d '' files < <(find "$dir" -maxdepth 1 -type f -print0)
    fi
    n=${#files[@]}
    m=$(($n / 2))
    local i j
    for ((i = 0; i <= m; i++)); do
        j=$((i + m + 1))
        echo "|"
        printf "%-*s  %s\n" "30" "$(get_file_or_direactory_symbol "${files[i]}")" "$(get_file_or_direactory_symbol "${files[j]}")"
    done
    echo -e "\n"
}

#handles all directory operations
directory_operations() {
    while true; do
        dir=$(pwd)
        echo -e "Current Directory: \n"
        list_directory "$dir" "0"
        op=1
        read -r -e -p "Press '..' to go to previous directory, '...' to jump two directory back 'O' for options and write the name of directory to move to it: " val
        if [[ $val == '..' ]]; then
            cd ..
        elif [[ $val == 'O' || $val == 'o' ]]; then
            op=0
        elif [[ $val == '...' ]]; then
            cd ../..
        elif [[ -d $val ]]; then
            cd "$val"
        else
            echo "Invalid Input. Try Again ..."
        fi
        if [[ $op == 0 ]]; then
            echo -e "\nThe following operations could be perfromed"
            print_array "${dir_operation[@]}"
            echo "Write the name of directory to enter the directory, and 'P' to exit the directory."
            option=$(read_value)
            case $option in
            "1")
                read -r -e -p "Enter the name of directory: " name
                echo "$name"
                mkdir "$name"
                echo "Directory created ..."
                ;;
            "2")
                read -r -e -p "Enter the directory name to be deleted: " -a input_array
                name="${input_array[*]}"
                if [ -n "$(find "$name" -maxdepth 1 \( -type f -o -type d \) -print -quit)" ]; then
                    clear
                    echo -e "The directory is not empty\n"
                    list_directory "$name" "0"
                    read -r -p "Do you want to delete it with all sub files and directory? (Y/N)" value
                    if [[ $value == 'y' || $value == 'Y' ]]; then
                        rm -r "$name"
                        echo "Directory deleted.."
                    else
                        echo "Operation Cancelled"
                    fi
                else
                    rm -r "$name"
                    echo "Directory deleted"
                fi

                ;;
            "3")
                read -r -p "Enter the name of directory: " name
                read -r -p "Enter the directory new name: " nname
                mv "$name" "$nname"
                echo "Directory renamed from $name to $nname"
                ;;

            "4")
                read -r -p "Enter the name of directory: " name
                perm=$(stat --format="%A" "$name")
                clear
                echo "$(file_or_directory_permission $perm $name)"

                ;;

            "5")
                permission=$(edit_permissions)
                echo "$permission"
                chmod "$permission" "$name"
                echo "Directory permission changed.."
                ;;

            "6")
                clear
                file_operations $dir
                option='m'
                ;;
            "7")
                dir_organizer
                ;;

            "e" | "E")
                echo "See you soon"
                exit
                ;;
            "m" | "M")
                return
                ;;
            *)
                echo "Invalid operation: $operation"
                ;;

            esac
            if [[ $option =~ [1-7] ]]; then
                echo "Press any key to continue...."
                read -n 1 -s
            fi
        fi
        clear
    done

}

# handles all file related operations
file_operations() {
    while true; do
        list_directory "$1" "1"
        print_array "${files_operation[@]}"
        operation=$(read_value)
        if [[ $operation == "m" || $operation == "M" ]]; then
            return

        elif [[ $operation == "e" || $operation == "E" ]]; then
            exit
        fi
        read -r -p "Enter the name of the file to be maniputed: " name
        if ! [[ -d "$name" ]]; then
            case $operation in
            "1")
                if ! [ -f "$name" ]; then
                    touch "$name"
                    echo "File created: $name"
                else
                    echo "File already present !!!"
                fi
                ;;
            "2")
                if [[ $name == *"*"* ]]; then
                    rm $name
                elif [ -f "$name" ]; then
                    rm "$name"
                    echo "File deleted: $name"
                else
                    echo "File does not exist: $name"
                fi
                ;;
            "3")
                echo "Edit file ${name}"
                ;;

            "4")
                read -r -p "Enter the file new name: " nname
                mv "$name" "$nname"
                echo "File renamed from $name to $nname"
                ;;

            "5")
                permission=$(edit_permissions)
                echo "$permission"
                chmod "$permission" "$name"
                echo "File permission changed.."
                ;;

            "6")
                file_info=($(ls -l $name))
                echo -e "The file info:\nName: $(file_or_directory_permission "${file_info[0]}" "$name")"
                echo -e "Owner: ${file_info[2]}\nSize: ${file_info[4]} bytes\nLast Modified Date: ${file_info[5]} ${file_info[6]} - Time: ${file_info[7]}\n"

                ;;

            *)
                echo "Invalid operation: $operation"
                ;;

            esac
        else
            echo "It seems to be not present in current directory. Redirecting ....."
        fi
        echo "Press any key to continue..."
        read -n 1 -s
        clear
    done
}

#start of the program
main() {
    while true; do
        clear
        echo -e "Welcome to the CLI tools.\n"
        echo -e "The following operations can be performed:"
        print_array "${functions[@]}"
        value=$(read_value)
        case $value in
        "1")
            clear
            echo -e "Select the type of manipulation you want to do: \n"
            directory_operations
            ;;

        "e" | "E")
            echo "See you soon"
            exit
            ;;
        *)
            echo "Wrong option $value. Please press correct key"
            ;;

        esac
    done
}
main
