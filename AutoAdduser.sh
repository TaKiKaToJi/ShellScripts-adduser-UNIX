#!/bin/bash

# Function to detect the operating system and set the appropriate admin group
detect_os() {
    if [ -f /etc/os-release ]; then
        # Source os-release to get the distribution name
        . /etc/os-release

        # Check ID and ID_LIKE to catch similar distributions
        if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
            ADMIN_GROUP="sudo"  # Ubuntu and Debian use the sudo group
        elif [[ "$ID" == "centos" || "$ID" == "rocky" || "$ID" == "almalinux" || "$ID_LIKE" == *"rhel"* ]]; then
            ADMIN_GROUP="wheel" # CentOS, Rocky, AlmaLinux, and RHEL use the wheel group
        else
            echo "Unsupported Linux distribution: $ID"
            exit 1
        fi
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

# Check if the users.txt file exists
if [ ! -f users.txt ]; then
    echo "Error: users.txt file not found!"
    exit 1
fi

# Read the users.txt file and process each user
while IFS=: read -r USERNAME PASSWORD; do
    add_user "$USERNAME" "$PASSWORD"
done < users.txt

echo "All users have been created."
echo "Displaying newly added users:"

# List only the newly added users from /etc/passwd
cut -d: -f1 /etc/passwd | grep -E "$(IFS=\|; echo "$(cut -d: -f1 users.txt | tr '\n' '|')" | sed 's/|$//')"
