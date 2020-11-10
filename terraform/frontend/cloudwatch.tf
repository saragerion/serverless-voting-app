resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "${local.verbose_service_name}-dashboard-${local.stack_name_postfix}"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/CloudFront", "Requests", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}" ]
                ],
                "region": "us-east-1",
                "title": "CloudFront - HTTP requests",
                "yAxis": {
                    "left": {
                        "showUnits": false
                    },
                    "right": {
                        "showUnits": false
                    }
                },
                "stat": "Sum",
                "period": 300,
                "liveData": true
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/CloudFront", "BytesUploaded", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}" ],
                    [ ".", "BytesDownloaded", ".", ".", ".", "." ]
                ],
                "region": "us-east-1",
                "title": "CloudFront - Data transfer",
                "yAxis": {
                    "left": {
                        "showUnits": false
                    },
                    "right": {
                        "showUnits": false
                    }
                },
                "period": 300,
                "liveData": true
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/CloudFront", "TotalErrorRate", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}" ],
                    [ ".", "4xxErrorRate", ".", ".", ".", ".", { "label": "Total4xxErrors" } ],
                    [ ".", "5xxErrorRate", ".", ".", ".", ".", { "label": "Total5xxErrors" } ],
                    [ { "expression": "(m4+m5+m6)/m7*100", "label": "5xxErrorByLambdaEdge", "id": "e1", "region": "us-east-1" } ],
                    [ "AWS/CloudFront", "LambdaExecutionError", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}", { "id": "m4", "stat": "Sum", "visible": false } ],
                    [ ".", "LambdaValidationError", ".", ".", ".", ".", { "id": "m5", "stat": "Sum", "visible": false } ],
                    [ ".", "LambdaLimitExceededErrors", ".", ".", ".", ".", { "id": "m6", "stat": "Sum", "visible": false } ],
                    [ ".", "Requests", ".", ".", ".", ".", { "id": "m7", "stat": "Sum", "visible": false } ]
                ],
                "region": "us-east-1",
                "title": "CloudFront - Error rate",
                "yAxis": {
                    "left": {
                        "showUnits": false
                    },
                    "right": {
                        "showUnits": false
                    }
                },
                "period": 300,
                "liveData": true
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/CloudFront", "TotalErrorRate", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}" ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "title": "Global error rate (4xx, 5xx)",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/CloudFront", "Requests", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}" ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "title": "HTTP traffic",
                "stat": "Sum",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 6,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/CloudFront", "Requests", "Region", "Global", "DistributionId", "${local.cloudfront_distribution_id}" ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "title": "HTTP requests / second (average)",
                "stat": "Average",
                "period": 1
            }
        }
    ]
}
EOF
}
