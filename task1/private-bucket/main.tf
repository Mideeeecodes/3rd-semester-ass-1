resource "aws_s3_bucket" "example" {
  bucket = "ola-mide"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## s3 bucket policy to get and put object
# resource "aws_s3_bucket_policy" "example" {
#   bucket = aws_s3_bucket.example.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = "*"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject"
#         ]
#         Resource = "${aws_s3_bucket.example.arn}/*"
#       }
#     ]
#   })
# }

##creating a user
resource "aws_iam_user" "example" {
  name = "example-user"
#   path = "/system/"
}

##attaching policy to user
resource "aws_iam_user_policy" "example" {
  name = "example-policy"
  user = aws_iam_user.example.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}

