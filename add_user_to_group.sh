#!/bin/bash
# Define an array of IAM user names
iam_users=("ade" "gbenga" "david" "tise" "tolu")

# Function to assign IAM users to the "admin" group
assign_users_to_group() {
    local group_name="admin"

    echo "Assigning users to the IAM group '$group_name'..."

    # Iterate through the array of IAM users
    for user in "${iam_users[@]}"; do
        echo "Adding user '$user' to group '$group_name'..."
        if aws iam add-user-to-group --group-name "$group_name" --user-name "$user"; then
            echo "Successfully added user '$user' to group '$group_name'."
        else
            echo "Failed to add user '$user' to group '$group_name'. Ensure the user exists and you have the necessary permissions."
        fi
    done
}

# Call the function
assign_users_to_group

