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
