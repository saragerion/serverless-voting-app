######################################################
# Video global tables and replicas
######################################################
resource "aws_dynamodb_table" "videos_primary" {
  # TODO: Got an error " A provider configuration reference must not be given in quotes" error when trying to reference like this 
  # provider = "aws.${local.primary_region}"
  provider = aws.eu-central-1

  count = local.is_primary ? 1 : 0
  name         = local.dynamodb_videos_resource_name
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
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
    name            = local.dynamodb_displayed_videos_index_name
    hash_key        = "isDisplayed"
    range_key       = "displayedFrom"
    projection_type = "ALL"
  }

  tags = local.tags
}

resource "aws_dynamodb_table" "videos_secondary" {
  provider = aws.us-east-1

  count = local.is_primary ? 1 : 0
  name         = local.dynamodb_videos_resource_name
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
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
    name            = local.dynamodb_displayed_videos_index_name
    hash_key        = "isDisplayed"
    range_key       = "displayedFrom"
    projection_type = "ALL"
  }

  tags = local.tags
}


resource "aws_dynamodb_global_table" "videos_global" {
  depends_on = [
    aws_dynamodb_table.videos_primary,
    aws_dynamodb_table.videos_secondary,
  ]

  provider = aws.eu-central-1

  name = local.dynamodb_videos_resource_name

  replica {
    region_name = local.primary_region
  }

  replica {
    region_name = local.secondary_region
  }
}

######################################################
# Votes global tables and replicas
######################################################
resource "aws_dynamodb_table" "votes_primary" {
  # TODO: Got an error " A provider configuration reference must not be given in quotes" error when trying to reference like this 
  # provider = "aws.${local.primary_region}"
  provider = aws.eu-central-1

  count = local.is_primary ? 1 : 0
  name         = local.dynamodb_votes_resource_name
  billing_mode = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
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


resource "aws_dynamodb_table" "votes_secondary" {
  provider = aws.us-east-1

  count = local.is_primary ? 1 : 0
  name         = local.dynamodb_votes_resource_name
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
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

resource "aws_dynamodb_global_table" "votes_global" {
  depends_on = [
    aws_dynamodb_table.votes_primary,
    aws_dynamodb_table.votes_secondary,
  ]

  provider = aws.eu-central-1

  name = local.dynamodb_votes_resource_name

  replica {
    region_name = local.primary_region
  }

  replica {
    region_name = local.secondary_region
  }
}