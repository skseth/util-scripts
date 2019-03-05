#!/bin/bash

fatal() {
    printf "\033[1;31m$1\033[0m\n"
}

info() {
    printf "$1"
}

check-submodule-exists() {
    local status=$(git submodule | awk '{print $2}' | grep "$1" | wc -l)
    echo "$status"
}

remove-submodule() {
    local smpath="$1"

    # source : https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
    read -p "Are you sure you want to remove submodule $sm?" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # source : https://stackoverflow.com/questions/1260748/how-do-i-remove-a-submodule/36593218#36593218
        # Remove the submodule entry from .git/config
        git submodule deinit -f "$smpath" > /dev/null || fatal "Error in submodule deinit for $sm"

        # Remove the submodule directory from the superproject's .git/modules directory
        rm -rf ".git/modules/$smpath" > /dev/null || fatal "Error in removing submodule $sm from .git/modules"

        # Remove the entry in .gitmodules and remove the submodule directory located at path/to/submodule
        git rm -f "$smpath" > /dev/null || fatal "Error in removing submodule folder $sm"
    fi
}


for sm in "$@"
do
    result=$(check-submodule-exists "$sm")
    if [[ "$result" == "1" ]]; then
        remove-submodule "$sm"
    else
        echo "No submodule $sm found. Skipping"
    fi
done

