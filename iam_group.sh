#!/bin/bash
create_iam_group() {
    local group_name="admin"
    local policy_arn="arn:aws:iam::aws:policy/AdministratorAccess"

    echo "Creating IAM group: $group_name"

    # Attempt to create the IAM group
    if aws iam create-group --group-name "$group_name" &>/dev/null; then
        echo "IAM group '$group_name' created successfully."
    else
        echo "Failed to create IAM group '$group_name'. It might already exist or you may not have the necessary permissions."
    fi

    # Attach the AdministratorAccess policy to the group
    echo "Attaching policy '$policy_arn' to group '$group_name'"
    if aws iam attach-group-policy --group-name "$group_name" --policy-arn "$policy_arn"; then
        echo "Policy '$policy_arn' attached successfully to group '$group_name'."
    else
        echo "Failed to attach policy '$policy_arn' to group '$group_name'."
    fi

}
create_iam_group
