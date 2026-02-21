import boto3

class EBSCleaner:
    def __init__(self, region='us-east-1', dry_run=True):
       
        self.ec2 = boto3.client('ec2', region_name=region)
        self.dry_run = dry_run

    def clean_orphan_volumes(self):
        print(f"Starting EBS cleanup in {self.ec2.meta.region_name}... (Dry Run: {self.dry_run})")
        
       
        paginator = self.ec2.get_paginator('describe_volumes')
        page_iterator = paginator.paginate(
            Filters=[{'Name': 'status', 'Values': ['available']}]
        )

        deleted_count = 0
        
       
        for page in page_iterator:
            for volume in page.get('Volumes', []):
                vol_id = volume['VolumeId']
                size = volume['Size']
                
                
                if self.dry_run:
                    print(f"[DRY RUN] Would delete orphan volume {vol_id} ({size} GB)")
                else:
                    try:
                        print(f"Deleting orphan volume {vol_id} ({size} GB)...")
                        self.ec2.delete_volume(VolumeId=vol_id)
                        deleted_count += 1
                    except Exception as e:
                        print(f"Error deleting {vol_id}: {str(e)}")
                        
        print(f"Cleanup complete. Volumes deleted: {deleted_count}")

if __name__ == "__main__":
    
    cleaner = EBSCleaner(dry_run=True)
    cleaner.clean_orphan_volumes()