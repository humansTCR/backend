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

#-------------------------------------------------------------------------------
# WEBSITE
#-------------------------------------------------------------------------------

resource "aws_s3_bucket" "site" {
  bucket = "humans-tcr"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

#-------------------------------------------------------------------------------
# DEPLOYMENT USER
#-------------------------------------------------------------------------------

resource "aws_iam_user" "deployer" {
  name = "humans-deployer"
}

resource "aws_iam_access_key" "deployer" {
  user    = "${aws_iam_user.deployer.name}"
  pgp_key = "keybase:xwvvvvwx"
}

resource "aws_iam_user_policy" "deployer" {
  name = "humans-tcr-deployer"
  user = "${aws_iam_user.deployer.name}"

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

output "deployer_secret_access_key" {
  value = "${aws_iam_access_key.deployer.encrypted_secret}"
}
