terraform {
  backend "s3" {
    bucket = "statestoragebucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "jenkinsgithub"{
    bucket = "jenkinsgithub"
    tags = {
        Name = "jenkinsgithub"
    }
}

resource "aws_lambda_function" "Function2" {
  function_name = "Function2"
  s3_bucket = "jenkinsgithub"
  s3_key = "Function2.zip"
  role          = aws_iam_role.AWSLambdaBasicExecutionRole.arn
  handler       = "Function2.lambda_handler"

  runtime = "python3.9"

  depends_on = [
    aws_s3_object.Function2Upload
  ]
}

resource "aws_lambda_function" "Function1" {
  function_name = "Function1"
  s3_bucket = "jenkinsgithub"
  s3_key = "Function1.zip"
  role          = aws_iam_role.InvokeOtherLambdaRole.arn
  handler       = "Function1.lambda_handler"

  runtime = "python3.9"

  depends_on = [
    aws_s3_object.Function1Upload
  ]
}

output "s3_acces_key_id" {
    value = aws_iam_access_key.S3_access_key.id
    description = "Secret Access Key ID for the User S3_jenkins"
    sensitive = true
}

output "s3_access_key" {
    value = aws_iam_access_key.S3_access_key.secret
    description = "Secret Access Key for the User S3_jenkins"
    sensitive = true
}