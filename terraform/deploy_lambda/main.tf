variable "region" {
  default = "eu-west-1"
}

variable "account_id" {}

provider "aws" {
  region = "${var.region}"
}

resource "aws_api_gateway_rest_api" "metrics" {
  name = "metrics"
}

resource "aws_api_gateway_resource" "metrics" {
  path_part = "metrics"
  parent_id = "${aws_api_gateway_rest_api.metrics.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.metrics.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.metrics.id}"
  resource_id   = "${aws_api_gateway_resource.metrics.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.metrics.id}"
  resource_id             = "${aws_api_gateway_resource.metrics.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.metrics.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.metrics.path}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "../lambda.zip"
  function_name    = "aws_metrics_exporter"
  role             = "${aws_iam_role.resource_monitor.arn}"
  handler          = "app.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${base64sha256(file("../lambda.zip"))}"
}

resource "aws_iam_role" "resource_monitor" {
  name = "resource_monitor"

  assume_role_policy = <<POLICY
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
POLICY
}

data "aws_iam_policy_document" "describe_resources" {
  statement {
    actions = [ 
      "ec2:DescribeAddresses",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
      "s3:ListAllMyBuckets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "describe_resources" {
  name = "describe_resources"
  path = "/"
  policy = "${data.aws_iam_policy_document.describe_resources.json}"
}

resource "aws_iam_role_policy_attachment" "resource_monitor_can_describe_resources" {
  role       = "${aws_iam_role.resource_monitor.name}"
  policy_arn = "${aws_iam_policy.describe_resources.arn}"
}

resource "aws_api_gateway_deployment" "test_deploy" {
  rest_api_id = "${aws_api_gateway_rest_api.metrics.id}"
  stage_name  = "test"
}
