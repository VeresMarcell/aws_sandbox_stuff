
resource "aws_s3_object" "Function1Upload" {
  bucket = aws_s3_bucket.jenkinsgithub.id
  key    = "Function1.zip"
  source = "../Lambda/Function1.zip"
}

resource "aws_s3_object" "Function2Upload" {
  bucket = aws_s3_bucket.jenkinsgithub.id
  key    = "Function2.zip"
  source = "../Lambda/Function2.zip"
}

resource "aws_iam_policy" "AWSLambdaBasicExecutionPolicy"{
    name = "AWSLambdaBasicExecutionPolicy"
    description = "Permissions to create CloudWatch logstreams and put logs into them"
      policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_role" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
    managed_policy_arns = [aws_iam_policy.AWSLambdaBasicExecutionPolicy.arn]
}

resource "aws_iam_policy" "InvokeOtherLambdaPolicy"{
    name = "InvokeOtherLambdaPolicy"
    description = "Invoke Lambda Functions with other Lambda Functions"

    policy = jsonencode(
    {
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ]
            Resource = aws_lambda_function.Function2.arn
        }
    ]
})
}

resource "aws_iam_role" "InvokeOtherLambdaRole"{
    name = "InvokeOtherLambdaRole"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
    managed_policy_arns = [aws_iam_policy.InvokeOtherLambdaPolicy.arn,aws_iam_policy.AWSLambdaBasicExecutionPolicy.arn]
}

resource "aws_iam_policy" "AWSS3FullAccessPolicy"{
    name = "AWSS3FullAccessPolicy"
    description = "Grants full access to jenkinsgithub S3 bucket"
    policy = jsonencode(
    {
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "s3:*",
                "s3-object-lambda:*"
                ]
            Resource = ["*"]
        }
    ]
    }
  )
}

resource "aws_iam_policy" "LambdaDeployPolicy" {
    name = "LambdaDeployPolicy"
    description = "Deploy code changes to lambda functions Function1 and Function2 automatically"
    policy = jsonencode(
    {
    Version = "2012-10-17",
    Statement = [
        {
            Sid = "Stmt1432812345671",
            Effect = "Allow",
            Action = [
                "lambda:GetFunction",
                "lambda:CreateFunction",
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration"
            ],
            Resource = [
                aws_lambda_function.Function1.arn,
                aws_lambda_function.Function2.arn
            ]
        },
        {
            Sid = "Stmt14328112345672",
            Effect = "Allow",
            Action = [
                "iam:Passrole"
            ],
            Resource = [
                aws_iam_role.InvokeOtherLambdaRole.arn,
                aws_iam_role.AWSLambdaBasicExecutionRole.arn
            ]
        }
    ]
    })
}

resource "aws_iam_user" "S3_jenkins" {
    name = "S3_jenkins"
}

resource "aws_iam_user_policy_attachment" "LambdaDeployAttach" {
    user = aws_iam_user.S3_jenkins.name
    policy_arn = aws_iam_policy.LambdaDeployPolicy.arn
}

resource "aws_iam_user_policy_attachment" "S3FullAccessAttach" {
    user = aws_iam_user.S3_jenkins.name
    policy_arn = aws_iam_policy.AWSS3FullAccessPolicy.arn
}

resource "aws_iam_access_key" "S3_access_key" {
    user = aws_iam_user.S3_jenkins.name
}