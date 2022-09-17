output "videos_table_name" {
  value = local.dynamodb_videos_resource_name
}

output "votes_table_name" {
  value = local.dynamodb_votes_resource_name
}

output "displayed_videos_index_name" {
  value = local.dynamodb_displayed_videos_index_name
}
