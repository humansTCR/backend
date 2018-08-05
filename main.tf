#-------------------------------------------------------------------------------
# AWS CONFIG
#-------------------------------------------------------------------------------

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-humans-tcr"
    key            = "tf-state"
    region         = "eu-central-1"
    dynamodb_table = "terraform-humans-tcr"
    encrypt        = true
    profile        = "humans-tcr"
  }
}

#-------------------------------------------------------------------------------
# S3 BUCKET
#-------------------------------------------------------------------------------

resource "aws_s3_bucket" "site" {
  bucket = "humans-tcr"

  website {
    index_document = "index.html"
  }
}

# resource "aws_s3_bucket_policy" "public_read" {
#   bucket = "${aws_s3_bucket.site.id}"

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "PublicReadGetObject",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": ["s3:GetObject"],
#       "Resource": ["${aws_s3_bucket.site.arn}"]
#     }
#   ]
# }
# POLICY
# }

#-------------------------------------------------------------------------------
# TRAVIS USER
#-------------------------------------------------------------------------------

resource "aws_iam_user" "travis" {
  name = "humans-travis"
}

resource "aws_iam_access_key" "travis" {
  user    = "${aws_iam_user.travis.name}"
  pgp_key = "keybase:xwvvvvwx"
}

resource "aws_iam_user_policy" "travis" {
  name = "humans-tcr-travis"
  user = "${aws_iam_user.travis.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.site.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.site.arn}"]
    }
  ]
}
EOF
}
