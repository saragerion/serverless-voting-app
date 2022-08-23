terraform {
    backend "s3" {
        encrypt = true
    }

    required_version = ">= 1.1.0, < 2.0.0"
}
