resource "aws_dynamodb_table" "videos" {
  name         = local.dynamodb_videos_resource_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "displayedFrom"
    type = "N"
  }

  attribute {
    name = "isDisplayed"
    type = "S"
  }

  global_secondary_index {
    name            = local.dynamodb_diplayed_videos_index_name
    hash_key        = "isDisplayed"
    range_key       = "displayedFrom"
    projection_type = "ALL"
  }

  tags = local.tags
}
