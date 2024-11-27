# CloudOps-Solutions-Script_for_IAM__management-

## Project BAckground

CloudOps Solutions is a growing company that recently adopted AWS to manage its cloud infrastructure. As the company scales, they have decided to automate the process of managing AWS Identity and Access Management (IAM) resources. This includes the creation of users, user groups, and the assignment of permissions for new hires, especially for their DevOps team.

## Objectives

1. To extend the script to inclue IAM management
2. Define IAM user names array
  The users array can be define as follows:
  `names=("ade" "gbenga" "david" "tise" "tolu")`
3. Create IAM users
 The function to create an IAM group from the previously created user via the AWS cli would look lik this:

```bash
    create_iam_group() {
    local group_name="admin"

    echo "Creating IAM group: $group_name"

    if aws iam create-group --group-name "$group_name" &>/dev/null; then
        echo "IAM group '$group_name' created successfully."
    else
        echo "Failed to create IAM group '$group_name'. It might already exist or you may not have the necessary permissions."
    fi
}
 ```

4. Attach administrative policy to group
   To attach an AWS managed policy to the admin group we just created we would need to modify the script as follows:

   ```bash
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

```

## Key Details:
- Policy ARN: The ARN for the AWS-managed AdministratorAccess policy is arn:aws:iam::aws:policy/AdministratorAccess.
- Error Handling:
If the group already exists, the script handles it gracefully.
If attaching the policy fails, an error message is displayed.
- Attaching Policy:
The aws iam attach-group-policy command is used to associate the policy with the group.

5. Iterate through the array of IAM user names and assign each user to the "admin" group using the AWS CLI
To assign users in the IAM user array, we could write another function like this:

``` bash
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

 
```
