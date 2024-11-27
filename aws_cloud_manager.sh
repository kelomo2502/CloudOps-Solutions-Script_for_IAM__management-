#!/bin/bash

# Load environment variables from the .env file
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create a .env file with the necessary variables."
    exit 1
fi

# Enable strict error handling
set -euo pipefail

# Validate required environment variables
: "${AWS_REGION:?AWS_REGION is not set in .env file.}"
: "${AMI_ID:?AMI_ID is not set in .env file.}"
: "${INSTANCE_TYPE:?INSTANCE_TYPE is not set in .env file.}"
: "${VPC_ID:?VPC_ID is not set in .env file.}"
: "${SUBNET_ID:?SUBNET_ID is not set in .env file.}"
: "${SECURITY_GROUP_ID:?SECURITY_GROUP_ID is not set in .env file.}"

# Display loaded environment variables
echo "Environment Variables Loaded:"
echo "Region: $AWS_REGION"
echo "AMI ID: $AMI_ID"
echo "Instance Type: $INSTANCE_TYPE"
echo "VPC ID: $VPC_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Security Group ID: $SECURITY_GROUP_ID"

# Declare an array to store resource IDs
declare -a RESOURCE_IDS

# Function to display usage information
usage() {
    echo "Usage: $0 <key-name>"
    echo "Example: $0 my-key-pair"
    exit 1
}

# Function to create S3 buckets for different departments

create_s3_buckets(){
    company="datawise"
    departments=("Marketing" "Sales" "HR" "Operations" "Media")

    for department in "${departments[@]}"; do
        # Generate a unique suffix using the current timestamp
        timestamp=$(date +%s)

        # Normalize the bucket name to lowercase and include the unique timestamp
        bucket_name=$(echo "${company}-${department}-data-bucket-${timestamp}" | tr '[:upper:]' '[:lower:]')

        # Create S3 bucket using AWS CLI
        aws s3api create-bucket --bucket "$bucket_name" --region "$AWS_REGION"
        if [ $? -eq 0 ]; then
            echo "S3 bucket '$bucket_name' created successfully."
        else
            echo "Failed to create S3 bucket '$bucket_name'."
        fi
    done
}



#Function to launch an EC2 instance
launch_ec2_instance() {
    local key_name=$1
    echo "Launching EC2 instance..."
    local instance_id
    instance_id=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --key-name "$key_name" \
        --subnet-id "$SUBNET_ID" \
        --security-group-ids "$SECURITY_GROUP_ID" \
        --region "$AWS_REGION" \
        --query "Instances[0].InstanceId" \
        --output text)
    echo "EC2 instance launched successfully. Instance ID: $instance_id"
    RESOURCE_IDS+=("$instance_id")
}

# Function to verify deployment
verify_deployment() {
    echo "Verifying deployment..."
    for resource_id in "${RESOURCE_IDS[@]}"; do
        if [[ $resource_id == *"i-"* ]]; then
            local instance_state
            instance_state=$(aws ec2 describe-instances \
                --instance-ids "$resource_id" \
                --region "$AWS_REGION" \
                --query "Reservations[0].Instances[0].State.Name" \
                --output text)
            echo "EC2 Instance $resource_id State: $instance_state"
        else
            echo "S3 Bucket $resource_id exists and is accessible."
        fi
    done
}

# Main function
main() {
    if [ $# -ne 1 ]; then
        usage
    fi

    local key_name=$1

    echo "Starting deployment..."
    create_s3_buckets
    launch_ec2_instance "$key_name"
    verify_deployment
    echo "Deployment complete."
}

# Call the main function with command-line arguments
main "$1"
