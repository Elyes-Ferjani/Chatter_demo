resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.messages_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.sqs_poll.arn}"
}