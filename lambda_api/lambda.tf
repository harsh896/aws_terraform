data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/main.js"
  output_path = "${path.module}/${local.zip_file}"
}
resource "aws_lambda_function" "test_lambda" {
  function_name = "ServerlessExample"
  s3_bucket = aws_s3_bucket.bucket.id
  s3_key    = "${local.zip_file}.${base64sha256(filemd5(local.zip_file))}"
  handler = "main.handler"
  runtime = "nodejs12.x"
  role = aws_iam_role.lambda_iam_role.arn
  environment {
    variables = {
      name = "serverless-lambda"
    }
  }
  depends_on = [aws_s3_bucket_object.bucket_object]
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = aws_lambda_function.test_lambda.id
}
resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.rest_api.id
   parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.rest_api.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}
resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.rest_api.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.test_lambda.invoke_arn
}
resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.rest_api.id
   resource_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.rest_api.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.test_lambda.invoke_arn
}
resource "aws_api_gateway_deployment" "gateway_deployment" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.rest_api.id
   stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.test_lambda.function_name
   principal     = "apigateway.amazonaws.com"
   source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

output "base_url" {
  value = aws_api_gateway_deployment.gateway_deployment.invoke_url
}