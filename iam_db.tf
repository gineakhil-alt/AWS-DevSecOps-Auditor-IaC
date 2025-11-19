# iam_db.tf

# --- 1. DynamoDB Table (Database) ---
resource "aws_dynamodb_table" "audit_findings_table" {
  name             = "AuditorFindings"
  billing_mode     = "PROVISIONED"
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "CheckName"
  range_key        = "ResourceId"

  attribute {
    name = "CheckName"
    type = "S" # String
  }
  attribute {
    name = "ResourceId"
    type = "S" # String
  }
}

# --- 2. IAM Role Trust Policy ---
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- 3. IAM Role Definition ---
resource "aws_iam_role" "auditor_lambda_role" {
  name               = "auditor-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# --- 4. Custom Permissions Policy (The Audit Logic Permissions) ---
data "aws_iam_policy_document" "auditor_policy_document" {
  # CloudWatch Logs (Mandatory for Lambda execution/debugging)
  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # iam_db.tf (Updated)

  # Statement 2: Read-Only Access for Security Audits
  statement {
    sid    = "AllowAuditReadActions"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets", # <--- ADD THIS LINE!!!
      "s3:GetBucketAcl",
      "s3:GetEncryptionConfiguration",
      "ec2:DescribeSecurityGroups",
      "iam:ListUsers",
      "s3:ListBuckets",
      "ec2:DescribeVolumes",
    ]
    resources = ["*"]
  }

  # DynamoDB Write Access (To save the audit results)
  statement {
    sid    = "AllowDynamoDBWrite"
    effect = "Allow"
    actions = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.audit_findings_table.arn] # Uses the table we just defined!
  }
}

# --- 5. Attach the Policy to the Role ---
resource "aws_iam_role_policy_attachment" "auditor_policy_attach" {
  role       = aws_iam_role.auditor_lambda_role.name
  policy_arn = aws_iam_policy.auditor_custom_policy.arn
}
# iam_db.tf (Adding the missing resource)

# --- 4.5. Create the Custom IAM Policy ---
# This resource takes the JSON policy (document) and creates the policy in AWS.
resource "aws_iam_policy" "auditor_custom_policy" {
  name   = "AuditorCustomPolicy"
  policy = data.aws_iam_policy_document.auditor_policy_document.json
}