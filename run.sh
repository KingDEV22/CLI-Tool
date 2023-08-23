#!/bin/bash

#Constants
functions=('Files Manipulation' 'Search Files or Text' 'News' 'Weather' 'Sports')
search_options=('Files' 'Directory' 'Text')
groups=("Owner" "Group" "Others")
dir_operation=('Create' 'Delete ' 'Update Name' 'Check Permissions' 'Edit Permissions' 'Directory Size' 'Current Path' 'File Operations' 'Organizer')
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
    read -r -e -p"Press E to exit, M for Previous Menu: " value
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

dir_traversal() {
    op1=$1
    case $op1 in
    "..")
        cd ..
        ;;
    "...")
        cd ../..
        ;;
    *)
        if [ -d "$op1" ]; then
            cd "$op1"
        fi
        ;;
    esac
    dir=$(pwd)
    echo -e "Current Directory: \n"
    list_directory "$dir" "0"
}

operations() {
    local n=$1
    shift # Remove the first argument (index) from the argument list
    for e in "${!dir_operation[@]}"; do
        if ((e < n)); then
            printf "%-*s  %s\n" "30" "$((e + 1)). ${dir_operation[$e]}" "$((e + 3 + n)). ${dir_operation[$e]}"
        else
            printf "%-*s\n" "30" "$((e + 1)). ${dir_operation[$e]}"
        fi
        # printf "%-*s  %s\n" "30" "$((e + 1)). ${dir_operation[$e]}" "$((j + 1)). ${dir_operation[$j]}"
    done
}

#handles all directory operations
directory_operations() {
    option=""
    while true; do
        clear
        dir_traversal "$option"
        echo -e "The following operations could be perfromed"
        printf "%-*s  %s\n" "30" "<- Directory" "<-Files"
        n=${#dir_operation[@]}
        operations $(($n - 2))
        echo -e "\nWrite the name of directory to enter the directory, \nPress '..' to go to previous directory, \nPress '...' to jump two directories back"
        option=$(read_value)
        if [[ $option != '..' || $option != '...' ]];then
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
            if [[ $name == '.' ]]; then
                name=$(pwd)
            fi
            perm=$(stat --format="%A" "$name")
            echo "$(file_or_directory_permission $perm $name)"
            echo "Press any key to continue..."
            read -n 1 -s
            ;;

        "5")
            permission=$(edit_permissions)
            echo "$permission"
            chmod "$permission" "$name"
            echo "Directory permission changed.."
            ;;
        "6")
            echo "Not implemented"
            ;;
        "7")
            echo -e "\nCurrent Path : $(pwd)"
            echo -e "\nPress any key to continue...."
            read -n 1 -s
            ;;

        "8")
            clear
            file_operations $dir
            option='m'
            ;;
        "9")
            dir_organizer
            ;;

        "e" | "E")
            echo "See you soon"
            exit
            ;;
        "m" | "M")
            return
            ;;
        "10")
            if ! [ -f "$name" ]; then
                touch "$name"
                echo "File created: $name"
            else
                echo "File already present !!!"
            fi
            ;;
        "11")
            if [[ $name == *"*"* ]]; then
                rm "$name"
            elif [ -f "$name" ]; then
                rm "$name"
                echo "File deleted: $name"
            else
                echo "File does not exist: $name"
            fi
            ;;
        "-")
            echo "Edit file ${name}"
            ;;

        "12")
            read -r -p "Enter the file new name: " nname
            mv "$name" "$nname"
            echo "File renamed from $name to $nname"
            ;;

        "14")
            permission=$(edit_permissions)
            echo "$permission"
            chmod "$permission" "$name"
            echo "File permission changed.."
            ;;

        "13")
            file_info=($(ls -l $name))
            echo -e "The file info:\nName: $(file_or_directory_permission "${file_info[0]}" "$name")"
            echo -e "Owner: ${file_info[2]}\nSize: ${file_info[4]} bytes\nLast Modified Date: ${file_info[5]} ${file_info[6]} - Time: ${file_info[7]}\n"

            ;;
        *)
            continue
            ;;

        esac
        echo -e "\nPress any key to continue...."
        read -n 1 -s
        fi
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
                    rm "$name"
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

#!/bin/bash

clear_part_of_screen() {
    local row=$1
    local col=$2
    tput cup $row $col # Move cursor to the specified position
    tput ed            # Clear from the cursor position to the end of the screen
}

# Example usage  # Clears from row 5, column 10 to the end of the screen

#search files

search_operations() {
    root=$(pwd)
    echo -e "The following search operations can be performed:"
    print_array "${search_options[@]}"
    while true; do

        option=$(read_value)
        case $option in
        "1")
            dir_traversal
            # echo -e "Press . if want to search in present directory.\n"
            read -p"Press '.' to search in working directory, S to select directory " dir
            if [[ $dir == 'S' ]]; then
                option=""
                while true; do
                    clear_part_of_screen 6 0
                    dir_traversal $option
                    echo -e "\nWrite the name of directory to enter the directory, \nPress '..' to go to previous directory \nPress '...' to jump two directories back\nPress 'S' to Stop"
                    option=$(read_value)
                    if [[ $option == 'S' ]]; then
                        root=$(pwd)
                        break
                    fi
                done
            elif [[ $dir != '.' ]]; then
                echo "Invalid Input!!!"
            fi

            read -r -e -p"Enter the file name to be search: " name
            path=$(find "$root" -name .git -prune -o -type f -name "$name" -print)
            echo -e "\n$path"
            echo "Press any key to continue..."
            read -n 1 -s

            ;;
        "e" | "E")
            echo "See you soon"
            exit
            ;;
        "m" | "M")
            return
            ;;
        esac
        clear_part_of_screen 4 0
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
        "2")
            clear
            search_operations
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
