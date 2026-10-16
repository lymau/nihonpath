terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# --- CloudFront Access Logging Bucket (Observability §10) ---

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.name_prefix}-${var.environment}-cdn-logs"
  force_destroy = var.environment == "dev"

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-cdn-logs"
    Environment = var.environment
    Purpose     = "cdn-access-logs"
  })
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  depends_on = [aws_s3_bucket_ownership_controls.logs]
  bucket     = aws_s3_bucket.logs.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- CloudFront Origin Access Control (OAC) ---

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.name_prefix}-${var.environment}-s3-oac"
  description                       = "CloudFront Origin Access Control for S3 storage origins"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- CloudFront Public Key & Key Group for Signed URLs (§8.2, §12.1) ---

resource "aws_cloudfront_public_key" "premium_signer" {
  comment     = "Public key for signing premium content URLs (${var.name_prefix}-${var.environment})"
  encoded_key = var.cloudfront_signing_public_key_pem
  name        = "${var.name_prefix}-${var.environment}-premium-key"
}

resource "aws_cloudfront_key_group" "premium_signers" {
  comment = "Key group for premium content CloudFront signed URLs (§8.2, §12.1)"
  items   = [aws_cloudfront_public_key.premium_signer.id]
  name    = "${var.name_prefix}-${var.environment}-premium-key-group"
}

# --- CloudFront Distribution (§4.2, §9.3, §12.1) ---

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.name_prefix} ${var.environment} content and audio distribution"
  price_class     = var.price_class

  origin {
    domain_name              = var.content_packs_bucket_regional_domain_name
    origin_id                = "content-packs-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  origin {
    domain_name              = var.audio_bucket_regional_domain_name
    origin_id                = "audio-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cdn-access-logs/"
  }

  # Default Cache Behavior: Content packs (Read-mostly)
  default_cache_behavior {
    target_origin_id       = "content-packs-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Ordered Cache Behavior: Premium content packs (Signed URL required §8.2, §12.1)
  ordered_cache_behavior {
    path_pattern           = "/premium/*"
    target_origin_id       = "content-packs-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    trusted_key_groups     = [aws_cloudfront_key_group.premium_signers.id]

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Ordered Cache Behavior: Pre-rendered audio (Read-mostly, long TTL)
  ordered_cache_behavior {
    path_pattern           = "/audio/*"
    target_origin_id       = "audio-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 2592000 # 30 days
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-cdn"
    Environment = var.environment
  })
}

# --- S3 Bucket Policies for CloudFront OAC (§12.1) ---

data "aws_iam_policy_document" "content_packs_oac" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${var.content_packs_bucket_arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "content_packs" {
  bucket = var.content_packs_bucket_id
  policy = data.aws_iam_policy_document.content_packs_oac.json
}

data "aws_iam_policy_document" "audio_oac" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${var.audio_bucket_arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "audio" {
  bucket = var.audio_bucket_id
  policy = data.aws_iam_policy_document.audio_oac.json
}

# --- Observability Alarms (§10, M0-4c) ---

resource "aws_cloudwatch_metric_alarm" "cdn_5xx_rate" {
  alarm_name          = "${var.name_prefix}-${var.environment}-cdn-5xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cdn_5xx_error_threshold_percent
  alarm_description   = "CloudFront 5xx error rate exceeds threshold"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
    Region         = "Global"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-cdn-5xx-alarm"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "cdn_4xx_rate" {
  alarm_name          = "${var.name_prefix}-${var.environment}-cdn-4xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cdn_4xx_error_threshold_percent
  alarm_description   = "CloudFront 4xx error rate exceeds threshold"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
    Region         = "Global"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-cdn-4xx-alarm"
    Environment = var.environment
  })
}
