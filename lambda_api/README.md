# aws_terraform

Used Resources

- AWS Lambda Function
- AWS API Gatewat Method
- AWS API Gatewat Integration
- AWS API Gatewat Deployment
- AWS Lambda Permission
- AWS IAM Role
- AWS IAM Policy
- AWS S3 Bucket
- AWS S3 Bucket Object
- Null Resource
- Archive File


1. Change the variables in terraform.tfvars file

2. Firstly, initialize terraform in the directory

- `terraform init`

3. To plan and apply terraform
 
- `terraform plan -out=tfplan.zip`
- `terraform apply "tfplan.zip"`

4. You will get the api base url in output

- `terraform output`

