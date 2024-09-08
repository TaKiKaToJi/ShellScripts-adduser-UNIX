#!/bin/bash

# Function to detect the operating system and set the appropriate admin group
detect_os() {
    if [ -f /etc/os-release ]; then
        # Source os-release to get the distribution name
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                ADMIN_GROUP="sudo"   # Ubuntu and Debian use the sudo group
                ;;
            centos|rocky|alma|rhel)
                ADMIN_GROUP="wheel"  # CentOS, Rocky, Alma, RHEL use the wheel group
                ;;
            *)
                echo "Unsupported Linux distribution: $ID"
                exit 1
                ;;
        esac
    else
        echo "Cannot detect the OS. Exiting."
        exit 1
    fi
}

# Function to add user, set password, and add to the admin group
add_user() {
    USERNAME=$1
    PASSWORD=$2

    # Add user
    sudo adduser $USERNAME

    # Set password
    echo "$USERNAME:$PASSWORD" | sudo chpasswd

    # Add user to the admin group (wheel or sudo)
    sudo usermod -aG $ADMIN_GROUP $USERNAME

    echo "User $USERNAME created and added to the $ADMIN_GROUP group."
}

# Detect the operating system to set the correct admin group
detect_os

# Array of users and passwords
declare -A users_passwords=(
    ["nueng"]="compcenter"
    ["nat"]="compcenter"
    ["wathit"]="compcenter"
)

# Loop through the array and add each user
for USERNAME in "${!users_passwords[@]}"; do
    add_user "$USERNAME" "${users_passwords[$USERNAME]}"
done

echo "All users have been created."
echo "Displaying newly added users:"

# List only the newly added users from /etc/passwd
cut -d: -f1 /etc/passwd | grep -E "$(IFS=\|; echo "${!users_passwords[*]}")"
