terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# --- Object Storage for Content Packs (§4.2, §9.3, §11.4) ---

resource "aws_s3_bucket" "content_packs" {
  bucket        = var.content_packs_bucket_name != "" ? var.content_packs_bucket_name : "${var.name_prefix}-${var.environment}-packs"
  force_destroy = var.environment == "dev"

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-packs"
    Environment = var.environment
    Purpose     = "content-packs"
  })
}

# WAJIB mengaktifkan versioning (§11.4)
resource "aws_s3_bucket_versioning" "content_packs" {
  bucket = aws_s3_bucket.content_packs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "content_packs" {
  bucket = aws_s3_bucket.content_packs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket konten privat, WAJIB blokir public access (§12.1)
resource "aws_s3_bucket_public_access_block" "content_packs" {
  bucket = aws_s3_bucket.content_packs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "content_packs" {
  bucket = aws_s3_bucket.content_packs.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag", "Content-Length", "Content-Range", "Accept-Ranges"]
    max_age_seconds = 3600
  }
}

# --- Object Storage for Pre-rendered Audio (§4.2, §9.3, §11.4) ---

resource "aws_s3_bucket" "audio" {
  bucket        = var.audio_bucket_name != "" ? var.audio_bucket_name : "${var.name_prefix}-${var.environment}-audio"
  force_destroy = var.environment == "dev"

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-audio"
    Environment = var.environment
    Purpose     = "audio-pra-render"
  })
}

# WAJIB mengaktifkan versioning (§11.4)
resource "aws_s3_bucket_versioning" "audio" {
  bucket = aws_s3_bucket.audio.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket audio privat, WAJIB blokir public access (§12.1)
resource "aws_s3_bucket_public_access_block" "audio" {
  bucket = aws_s3_bucket.audio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag", "Content-Length", "Content-Range", "Accept-Ranges"]
    max_age_seconds = 3600
  }
}

# --- Presigned URL IAM Policy (§8.2, §12.1) ---

data "aws_iam_policy_document" "presigned_url_access" {
  statement {
    sid    = "AllowS3ObjectReadForPresigning"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [
      "${aws_s3_bucket.content_packs.arn}/*",
      "${aws_s3_bucket.audio.arn}/*",
    ]
  }

  statement {
    sid    = "AllowS3ListBucketForPresigning"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.content_packs.arn,
      aws_s3_bucket.audio.arn,
    ]
  }
}

resource "aws_iam_policy" "presigned_url_access" {
  name        = "${var.name_prefix}-${var.environment}-s3-presigned-url-access"
  description = "Policy for backend API to generate S3 presigned URLs for premium packs and audio (§8.2, §12.1)"
  policy      = data.aws_iam_policy_document.presigned_url_access.json

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-s3-presigned-url-access"
    Environment = var.environment
  })
}
