#!/bin/bash

USERS_FILE="users.txt"

# Function to detect the operating system and set the appropriate admin group
detect_os_adduser() {
  if [ -f /etc/redhat-release ]; then
    OS="Red Hat-Based"
    ADMIN_GROUP="wheel"
  elif [ -f /etc/debian_version ]; then
    OS="Debian-Based"
    ADMIN_GROUP="sudo"
  else
    echo "Unsupported OS. Exiting."
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

# Function to manage users via the users.txt file
manage_users() {
    if [ ! -f "$USERS_FILE" ]; then
        echo "File users.txt does not exist. Creating users.txt..."
        touch "$USERS_FILE"
    fi

    echo "Opening users.txt for editing..."
    nano "$USERS_FILE"
}

# Function to add users from the users.txt file
add_users_from_file() {
    if [ ! -f "$USERS_FILE" ]; then
        echo "File users.txt not found. Exiting."
        exit 1
    fi

    while IFS=: read -r username password; do
        if [[ -n "$username" && -n "$password" ]]; then
            add_user "$username" "$password"
        else
            echo "Skipping invalid entry in users.txt: $username:$password"
        fi
    done < "$USERS_FILE"

    echo "All users from $USERS_FILE have been added."
}

# Function to delete this script
delete_script() {
    echo "Deleting this script..."
    rm -- "$0"
    echo "Script deleted."
}

# Main menu for user interaction
echo "Choose an option:"
echo "1. Add user"
echo "2. Manage users"
echo "3. Exit and delete this script"
read -p "Enter your choice [1-3]: " choice

detect_os

case "$choice" in
    1)
        manage_users
        add_users_from_file
        ;;
    2)
        manage_users
        ;;
    3)
        delete_script
        exit 0
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac
