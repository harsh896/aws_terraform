resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "lambda-function"
  tags = {
    Name        = "My Bucket"
  }
}
resource "aws_s3_bucket_object" "bucket_object" {
  key        = "${local.zip_file}.${base64sha256(filemd5(local.zip_file))}"
  bucket     = aws_s3_bucket.bucket.id
  source     = local.zip_file
  etag       = filemd5(local.zip_file)
  depends_on = [aws_s3_bucket.bucket, data.archive_file.init]
}
resource "null_resource" "lambda_invoke" {
  provisioner "local-exec" {
    command = "aws lambda invoke --region=${var.region} --function-name=${aws_lambda_function.test_lambda.id} --profile=${var.profile} ${local.output}"
  }
  triggers = {
    all-time = timestamp()
  }
}

resource "aws_s3_bucket_object" "invoke_output" {
  key        = "${local.output}.${base64sha256(filemd5(local.output))}"
  bucket     = aws_s3_bucket.bucket.id
  source     = local.output
  etag       = filemd5(local.output)
  depends_on = [null_resource.lambda_invoke]
}