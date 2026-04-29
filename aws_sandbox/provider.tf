provider "aws" {
  region = "us-east-1"
 
  assume_role {
    role_arn     = "arn:aws:iam::605454153191:role/AWSSandboxAutomation"
    session_name = "sandbox-terraform-session"
  }
}