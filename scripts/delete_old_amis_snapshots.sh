#!/bin/bash

# Set the retention period (2 years)
RETENTION_DAYS=730

# Get the current date in seconds since epoch
CURRENT_DATE=$(date +%s)

# Step 1: Find and delete AMIs older than 2 years
echo "Checking for AMIs older than 2 years..."
aws ec2 describe-images --owners self --query 'Images[?CreationDate<=`'$(date --date="-$RETENTION_DAYS days" --utc +%Y-%m-%dT%H:%M:%S)`'].ImageId' --output text | while read AMI_ID; do
    # Deregister the AMI
    echo "Deregistering AMI: $AMI_ID"
    aws ec2 deregister-image --image-id $AMI_ID
    
    # Step 2: Delete associated snapshots of the AMI
    echo "Deleting associated snapshots for AMI: $AMI_ID"
    aws ec2 describe-images --image-ids $AMI_ID --query 'Images[].BlockDeviceMappings[].Ebs.SnapshotId' --output text | while read SNAPSHOT_ID; do
        if [ -n "$SNAPSHOT_ID" ]; then
            echo "Deleting snapshot: $SNAPSHOT_ID"
            aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID
        fi
    done
done

# Step 3: Find and delete snapshots older than 2 years that are not associated with an AMI
echo "Checking for snapshots older than 2 years..."
aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[?StartTime<=`'$(date --date="-$RETENTION_DAYS days" --utc +%Y-%m-%dT%H:%M:%S)`'].SnapshotId' --output text | while read SNAPSHOT_ID; do
    if [ -n "$SNAPSHOT_ID" ]; then
        echo "Deleting snapshot: $SNAPSHOT_ID"
        aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID
    fi
done

echo "Script execution completed."
