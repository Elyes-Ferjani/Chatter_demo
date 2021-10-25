resource "aws_ssm_parameter" "sqs_url" {
  name  = "SQS_URL"
  type  = "String"
  value = "${aws_sqs_queue.messages_queue.url}"
}