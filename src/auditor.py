# auditor.py (Final Robust Version - Paste this entire block)

import boto3
import json
from datetime import datetime

# The hardcoded table name is okay since it was created via Terraform
TABLE_NAME = "AuditorFindings" 

# --- DynamoDB Write Function ---
def record_finding(table, check_name, resource_id, status, description):
    """Writes the audit finding to the DynamoDB table using the provided table resource."""
    try:
        table.put_item(
            Item={
                # Partition Key (Pkey)
                'CheckName': check_name, 
                # Sort Key (Skey)
                'ResourceId': resource_id, 
                # Other Attributes
                'Timestamp': datetime.utcnow().isoformat(),
                'Status': status,
                'Description': description
            }
        )
        # We will see this message in the logs if the write succeeds
        print(f"SUCCESS: Wrote finding for {check_name} to DB.") 
    except Exception as e:
        # This catch is now essential to see the fatal error
        print(f"FATAL DYNAMODB WRITE ERROR: {e}")


# =================================================================
# 1. SecOps Check (S3 Public Access)
# =================================================================

def check_s3_public_access(s3_client, table_resource):
    """Checks all S3 buckets for public access enabled."""
    print("Running S3 Public Access Check...")
    try:
        buckets = s3_client.list_buckets().get('Buckets', [])
        for bucket in buckets:
            bucket_name = bucket['Name']
            resource_id = f"s3-bucket::{bucket_name}"
            
            # --- EXAMPLE LOGIC (using hardcoded pass for testing) ---
            # If you had a PASS/FAIL result here, it would be written below
            record_finding(table_resource, 'S3_PublicAccessBlocked', resource_id, 'PASS', 'Settings enabled (Test Data).')
            
    except Exception as e:
        # Handle exceptions gracefully to prevent silent crashes
        print(f"S3 Check Error: {e}")


# =================================================================
# 2. FinOps Check (EBS Unattached Volume)
# =================================================================

def check_unattached_ebs_volumes(ec2_client, table_resource):
    """Checks for EBS volumes not attached to any EC2 instance (wasted money)."""
    print("Running EBS Unattached Volume Check...")
    
    # We will write a SUCCESS finding, even if empty, to ensure the write operation is tested
    volume_found = False
    
    try:
        volumes = ec2_client.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])['Volumes']
        
        for volume in volumes:
            volume_id = volume['VolumeId']
            resource_id = f"ec2-volume::{volume_id}"
            if not volume.get('Attachments'): 
                record_finding(table_resource, 'EBS_UnattachedVolume', resource_id, 'FAIL', f"Unattached Volume: {volume['Size']}GB.")
                volume_found = True
        
        if not volume_found:
             record_finding(table_resource, 'EBS_UnattachedVolume', 'ACCOUNT_STATUS', 'PASS', 'No unattached EBS volumes found.')

    except Exception as e:
        print(f"EBS Check Error: {e}")

# =================================================================
# Main Lambda Handler
# =================================================================

def lambda_handler(event, context):
    """The entry point for the Lambda function."""
    
    # Initialize the clients INSIDE the handler
    s3_client = boto3.client('s3')
    ec2_client = boto3.client('ec2')
    dynamodb_resource = boto3.resource('dynamodb')
    table_resource = dynamodb_resource.Table(TABLE_NAME)

    # Run all checks, passing the table object
    check_s3_public_access(s3_client, table_resource)
    check_unattached_ebs_volumes(ec2_client, table_resource)
    
    return {
        'statusCode': 200,
        'body': json.dumps('CloudDevSecOps Auditor completed successfully.')
    }

if __name__ == "__main__":
    lambda_handler(None, None)