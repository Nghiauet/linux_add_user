#!/bin/bash

# Check if the script is being run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check if a username has been provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 username"
    exit 1
fi

# Get the username from the script arguments
USERNAME=$1

# Update password variable
PASSWORD='xxx@123'

# Create a new user with the provided username, home directory, and set the default shell to bash
useradd -m -d /home/"$USERNAME" -s /bin/bash "$USERNAME"

# Check if the user was created successfully
if [ $? -eq 0 ]; then
    echo "User $USERNAME has been created successfully."
else
    echo "Failed to create user $USERNAME."
    exit 1
fi

# Set the user's password
echo $USERNAME:$PASSWORD | chpasswd

echo "Password for $USERNAME has been set to '$PASSWORD'."

# Ask whether to grant root privileges
read -p "Do you want to grant $USERNAME root privileges? (y/n) " grant
if [[ $grant == [Yy]* ]]; then
    # Determine the group to use for granting sudo privileges ('sudo' for Debian-based, 'wheel' for others)
    if grep -q '^sudo:' /etc/group; then
        GROUP_TO_ADD='sudo'
    else
        GROUP_TO_ADD='wheel'
    fi
    # Add the user to the appropriate group
    usermod -aG $GROUP_TO_ADD $USERNAME
    if [ $? -eq 0 ]; then
        echo "$USERNAME has been granted root privileges."
    else
        echo "Failed to grant root privileges to $USERNAME."
    fi
fi

# The script ends here. You can add additional commands if needed.

exit 0
