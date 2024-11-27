#!/bin/bash
manage_iam_users_and_group() {
    local group_name="admin"
    local policy_arn="arn:aws:iam::aws:policy/AdministratorAccess"
    local iam_users=("ade" "gbenga" "david" "tise" "tolu")

    echo "Starting IAM user and group management..."

    # Step 1: Create the IAM group
    echo "Creating IAM group: $group_name"
    if aws iam create-group --group-name "$group_name" &>/dev/null; then
        echo "IAM group '$group_name' created successfully."
    else
        echo "Failed to create IAM group '$group_name'. It might already exist or you may not have the necessary permissions."
    fi

    # Step 2: Attach the AdministratorAccess policy to the group
    echo "Attaching policy '$policy_arn' to group '$group_name'"
    if aws iam attach-group-policy --group-name "$group_name" --policy-arn "$policy_arn"; then
        echo "Policy '$policy_arn' attached successfully to group '$group_name'."
    else
        echo "Failed to attach policy '$policy_arn' to group '$group_name'."
    fi

    # Step 3: Iterate through the user array and create IAM users
    for user in "${iam_users[@]}"; do
        echo "Creating IAM user: $user"
        if aws iam create-user --user-name "$user" &>/dev/null; then
            echo "IAM user '$user' created successfully."
        else
            echo "Failed to create IAM user '$user'. It might already exist or you may not have the necessary permissions."
        fi

        # Step 4: Add each user to the "admin" group
        echo "Adding user '$user' to group '$group_name'"
        if aws iam add-user-to-group --group-name "$group_name" --user-name "$user"; then
            echo "Successfully added user '$user' to group '$group_name'."
        else
            echo "Failed to add user '$user' to group '$group_name'. Ensure the user exists and you have the necessary permissions."
        fi
    done

    echo "IAM user and group management process complete."
}
manage_iam_users_and_group
