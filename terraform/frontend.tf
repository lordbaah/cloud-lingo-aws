# Generate unique suffix for the frontend bucket
resource "random_string" "frontend_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Define origin ID
locals {
  s3_origin_id = "CloudLingoFrontendOrigin"
}

# Create the private S3 bucket for hosting the frontend
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-frontend-${random_string.frontend_suffix.result}"
  force_destroy = true

  tags = {
    Name        = "CloudLingo Frontend Bucket"
    Environment = "Dev"
  }
}

# Create CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "${var.project_name}-frontend-oac"
  description                       = "CloudFront OAC for frontend bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Generate IAM policy for S3 bucket to allow access from CloudFront
data "aws_iam_policy_document" "frontend_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.frontend.arn,
      "${aws_s3_bucket.frontend.arn}/*"
    ]

    # ⚠️ IMPORTANT:
    # The condition block below ensures that ONLY your specific CloudFront distribution
    # can access this S3 bucket, using AWS:SourceArn match.
    #
    # However, it creates a circular dependency:
    # - The policy needs the CloudFront distribution ARN
    # - But the CloudFront distribution waits for this policy to be applied
    #
    # ✅ To avoid this Terraform cycle error, this condition block is commented out.
    # ✅ You can uncomment it and re-apply Terraform AFTER the initial deployment.

    # condition {
    #   test     = "StringEquals"
    #   variable = "AWS:SourceArn"
    #   values   = [aws_cloudfront_distribution.frontend.arn]
    # }

    # TODO: After first `terraform apply`, uncomment the `condition` block above
    # and run `terraform apply` again to secure bucket access to this specific CloudFront distribution.
  }
}


resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend_policy.json
}

# CloudFront distribution pointing to private S3
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }


  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "CloudLingo Frontend CDN"
    Environment = "Dev"
  }

  depends_on = [aws_s3_bucket_policy.frontend]
}
