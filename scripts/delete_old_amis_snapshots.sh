#!/bin/bash

# Set the retention period (2 years)
RETENTION_DAYS=730

# Get the cutoff date in the required format (ISO 8601)
CUTOFF_DATE=$(date --date="-$RETENTION_DAYS days" --utc +%Y-%m-%dT%H:%M:%SZ)

# Step 1: Find and delete AMIs older than 2 years
echo "Checking for AMIs older than 2 years..."
OLD_AMIS=$(aws ec2 describe-images --owners self --query "Images[?CreationDate<=\`$CUTOFF_DATE\`].ImageId" --output text)

for AMI_ID in $OLD_AMIS; do
    if [ -n "$AMI_ID" ]; then
        # Deregister the AMI
        echo "Deregistering AMI: $AMI_ID"
        aws ec2 deregister-image --image-id "$AMI_ID"

        # Step 2: Delete associated snapshots of the AMI
        echo "Deleting associated snapshots for AMI: $AMI_ID"
        SNAPSHOT_IDS=$(aws ec2 describe-images --image-ids "$AMI_ID" --query 'Images[].BlockDeviceMappings[].Ebs.SnapshotId' --output text)

        for SNAPSHOT_ID in $SNAPSHOT_IDS; do
            if [ -n "$SNAPSHOT_ID" ]; then
                echo "Deleting snapshot: $SNAPSHOT_ID"
                aws ec2 delete-snapshot --snapshot-id "$SNAPSHOT_ID"
            fi
        done
    fi
done

# Step 3: Find and delete snapshots older than 2 years that are not associated with an AMI
echo "Checking for snapshots older than 2 years..."
OLD_SNAPSHOTS=$(aws ec2 describe-snapshots --owner-ids self --query "Snapshots[?StartTime<=\`$CUTOFF_DATE\`].SnapshotId" --output text)

for SNAPSHOT_ID in $OLD_SNAPSHOTS; do
    if [ -n "$SNAPSHOT_ID" ]; then
        echo "Deleting snapshot: $SNAPSHOT_ID"
        aws ec2 delete-snapshot --snapshot-id "$SNAPSHOT_ID"
    fi
done

echo "Script execution completed."
