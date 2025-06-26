# Generate unique 6-char lowercase suffix for buckets
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# S3 Bucket: Request
resource "aws_s3_bucket" "request_bucket" {
  bucket = "${var.project_name}-request-${random_string.bucket_suffix.result}"

  force_destroy = true

  tags = {
    Name        = "CloudLingo Request Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "request_lifecycle" {
  bucket = aws_s3_bucket.request_bucket.id

  rule {
    id     = "delete-after-30-days"

    filter {
      prefix = "logs/"
    }

    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

# S3 Bucket: Response
resource "aws_s3_bucket" "response_bucket" {
  bucket = "${var.project_name}-response-${random_string.bucket_suffix.result}"

  force_destroy = true

  tags = {
    Name        = "CloudLingo Response Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "response_lifecycle" {
  bucket = aws_s3_bucket.response_bucket.id

  rule {
    id     = "delete-after-30-days"

    filter {
      prefix = "logs/"
    }

    status = "Enabled"

    expiration {
      days = 30
    }
  }
}
