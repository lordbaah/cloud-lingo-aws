# 1. Trust policy: allow Lambda to assume this role
data "aws_iam_policy_document" "cloudlingo_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# 2. Create the IAM Role
resource "aws_iam_role" "cloudlingo_translate_role" {
  #name               = "cloudlingo-translate-role"
  name = var.cloudlingo_role_name
  assume_role_policy = data.aws_iam_policy_document.cloudlingo_assume_role.json
}

# 3. Policy: Translate, S3 access, CloudWatch logs
data "aws_iam_policy_document" "cloudlingo_policy_doc" {
  statement {
    effect = "Allow"
    actions = ["translate:TranslateText"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.request_bucket.arn}/*",
      "${aws_s3_bucket.response_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

# 4. Create the policy from the document
resource "aws_iam_policy" "cloudlingo_policy" {
  #name        = "cloudlingo-translate-s3-policy"
  name = var.cloudlingo_policy_name
  description = "Allows AWS Translate access and S3 read/write for CloudLingo"
  policy      = data.aws_iam_policy_document.cloudlingo_policy_doc.json
}

# 5. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "cloudlingo_policy_attach" {
  role       = aws_iam_role.cloudlingo_translate_role.name
  policy_arn = aws_iam_policy.cloudlingo_policy.arn
}
