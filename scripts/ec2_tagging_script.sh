#!/bin/bash

# Set the AWS region you want to work with
REGION="us-east-1"  # Replace with your target region

# Tags to add to the EC2 instances and EBS volumes (key-value pairs)
TAG_KEY="Environment"
TAG_VALUE="Production"

# Retrieve a list of all EC2 instance IDs in the specified region
INSTANCE_IDS=$(aws ec2 describe-instances \
    --region $REGION \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

# Check if any instances were found
if [ -z "$INSTANCE_IDS" ]; then
  echo "No EC2 instances found in region $REGION"
  exit 1
fi

echo "Found the following EC2 instances in region $REGION:"
echo "$INSTANCE_IDS"

# Add the tag to each EC2 instance and their associated EBS volumes
for INSTANCE_ID in $INSTANCE_IDS; do
  echo "Adding tag $TAG_KEY=$TAG_VALUE to instance $INSTANCE_ID"
  
  # Tag the EC2 instance
  aws ec2 create-tags \
    --region $REGION \
    --resources $INSTANCE_ID \
    --tags Key=$TAG_KEY,Value=$TAG_VALUE
  
  # Retrieve the EBS volume IDs attached to the EC2 instance
  VOLUME_IDS=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query "Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId" \
    --output text)
  
  # Add the tag to each attached EBS volume
  for VOLUME_ID in $VOLUME_IDS; do
    echo "Adding tag $TAG_KEY=$TAG_VALUE to EBS volume $VOLUME_ID"
    aws ec2 create-tags \
      --region $REGION \
      --resources $VOLUME_ID \
      --tags Key=$TAG_KEY,Value=$TAG_VALUE
  done

done

echo "Tagging of EC2 instances and EBS volumes completed."
