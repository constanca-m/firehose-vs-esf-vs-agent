//resource "aws_s3_bucket" "firewall_logs_bucket" {
//  count = var.create_firehose == 0 ? 1 : 0
//
//  bucket        = "${var.resource_name_prefix}-firewall-logs"
//  force_destroy = true
//}
//
//# Associate S3 logs notification with queue
//resource "aws_s3_bucket_notification" "bucket_notification_queue" {
//  count = var.create_firehose == 0 ? 1 : 0
//
//  bucket = aws_s3_bucket.firewall_logs_bucket[0].id
//
//  queue {
//    queue_arn     = aws_sqs_queue.queue[0].arn
//    events        = ["s3:ObjectCreated:*"]
//    #filter_suffix = ".gz"
//  }
//}


#resource "aws_s3_bucket_public_access_block" "access_block" {
#  count = var.create_firehose == 0 ? 1 : 0
#
#  bucket                  = aws_s3_bucket.firewall_logs_bucket[0].id
#  block_public_acls       = false
#  block_public_policy     = false
#  ignore_public_acls      = false
#  restrict_public_buckets = false
#}