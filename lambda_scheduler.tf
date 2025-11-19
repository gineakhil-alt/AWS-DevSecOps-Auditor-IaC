# lambda_scheduler.tf

# --- 1. Lambda Function Definition ---
resource "aws_lambda_function" "auditor_function" {
  function_name    = "CloudDevSecOpsAuditor"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  handler          = "auditor.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 128
  
  role             = aws_iam_role.auditor_lambda_role.arn
  depends_on = [
    data.archive_file.lambda_zip,
    aws_iam_role_policy_attachment.auditor_policy_attach
  ]
}

# --- 2. EventBridge Rule (Scheduler) ---
resource "aws_cloudwatch_event_rule" "auditor_schedule" {
  name                = "auditor-schedule-rule"
  description         = "Triggers the auditor every 6 hours"
  # Runs at 0 minutes past the hour, every 6th hour
  schedule_expression = "cron(0 0/6 * * ? *)" 
}

# --- 3. EventBridge Target (The Lambda Function) ---
resource "aws_cloudwatch_event_target" "auditor_lambda_target" {
  rule = aws_cloudwatch_event_rule.auditor_schedule.name
  arn  = aws_lambda_function.auditor_function.arn
}

# --- 4. Permission for EventBridge to call Lambda ---
resource "aws_lambda_permission" "allow_cloudwatch_to_call_auditor" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auditor_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auditor_schedule.arn
}