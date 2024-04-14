# 書籍には versioning, serverside_encryption などの引数があった
# それらは deplicated になっていて、現在は別 resource で定義が推奨されている
# aws_s3_bucket で定義してしまうと、それらの設定変更を検知できないため
resource "aws_s3_bucket" "private" {
    bucket = "private-pragmatic-terraform"
}

resource "aws_s3_bucket_versioning" private {
  bucket = aws_s3_bucket.private.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
    bucket = aws_s3_bucket.private.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "private" {
    bucket = aws_s3_bucket.private.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# 書籍には acl, cors_rule などの引数があった
# それらは deplicated になっていて、現在は別 resource で定義が推奨されている
# aws_s3_bucket で定義してしまうと、それらの設定変更を検知できないため
resource "aws_s3_bucket" "public" {
    bucket = "public-pragmatic-terraform"
}

resource "aws_s3_bucket_acl" "public" {
    acl = "public-read" # ref: https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/acl-overview.html
    bucket = aws_s3_bucket.public.id
}

resource "aws_s3_bucket_cors_configuration" "public" {
    bucket = aws_s3_bucket.public.id

    cors_rule {
        allowed_origins = ["https://example.com"]
        allowed_methods = ["GET"]
        allowed_headers = ["*"]
        max_age_seconds = 3000
    }
}

# 書籍には acl, cors_rule などの引数があった
# それらは deplicated になっていて、現在は別 resource で定義が推奨されている
# aws_s3_bucket で定義してしまうと、それらの設定変更を検知できないため
resource "aws_s3_bucket" "alb_log" {
    bucket = "alb-log-pragmatic-terraform"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
    bucket = aws_s3_bucket.alb_log.id

    rule {
        id = "alb_log"

        expiration {
            days = "180"
        }
        status = "Enabled"
    }
}

resource "aws_s3_bucket_policy" "alb_log" {
    bucket = aws_s3_bucket.alb_log.id
    policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
    statement {
        effect  = "Allow"
        actions = ["s3:PubObject"]
        resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

        principals {
          type = "AWS"
          identifiers = ["582318560864"]
        }
    }
}

resource "aws_s3_bucket" "fource_destroy" {
    bucket = "force-destroy-pragmatic-terraform"
    force_destroy = true
}