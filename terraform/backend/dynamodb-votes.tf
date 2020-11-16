resource "aws_dynamodb_table" "votes" {
  name         = local.dynamodb_votes_resource_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "videoId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "videoId"
    type = "S"
  }

  tags = local.tags
}
