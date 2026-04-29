terraform {
    backend "s3" {
    bucket         = "ashi0412-tfstate-bucket" # Replace with your S3 bucket name
    #key            = "sandboxfw/terraform.tfstate" # Specify the state file path within the bucket    
    key            = "sandboxautomation/terraform.tfstate" # Specify the state file path within the bucket    
    region         = "us-east-1" # Specify your AWS region
    dynamodb_table = "terraform-lock-table" # Replace with your DynamoDB table name for locking
    encrypt        = true
  }
}
