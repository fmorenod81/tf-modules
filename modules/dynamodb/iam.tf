# -----------------------------------------------------------------------------
# Dev IAM User for DynamoDB Access
# -----------------------------------------------------------------------------

resource "aws_iam_user" "dev_db_user" {
  name = local.iam_user_name
  tags = var.tags
}

resource "aws_iam_user_policy" "dynamodb_access" {
  name = "${var.workload_name}-dynamodb-access"
  user = aws_iam_user.dev_db_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      }
    ]
  })
}
