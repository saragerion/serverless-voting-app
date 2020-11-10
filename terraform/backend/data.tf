data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "./../../src/backend/health/index.js"
    output_path   = "lambda_function.zip"
}
