resource "aws_sns_topic" "source_bucket_event_sns_topic" {
  name = "intro-pipeline-task-topic-terraform"

  tags = {
    project_name = "Introductory Pipeline Task"
  }
}

resource "aws_sns_topic" "datalake_bucket_event_sns_topic" {
  name = "intro-pipeline-task-datalake-topic-terraform"

  tags = {
    project_name = "Introductory Pipeline Task"
  }
}

resource "aws_sns_topic_policy" "source_sns_policy" {
  arn = aws_sns_topic.source_bucket_event_sns_topic.arn

  policy = data.aws_iam_policy_document.source_sns_topic_policy.json
}

resource "aws_sns_topic_policy" "datalake_sns_policy" {
  arn = aws_sns_topic.datalake_bucket_event_sns_topic.arn

  policy = data.aws_iam_policy_document.datalake_sns_topic_policy.json
}


data "aws_iam_policy_document" "source_sns_topic_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.source_bucket_event_sns_topic.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["114888082308"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.source_bucket.arn]
    }

  }
}

data "aws_iam_policy_document" "datalake_sns_topic_policy" {
  statement {
    sid    = "s3 publish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.datalake_bucket_event_sns_topic.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["114888082308"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.datalake_bucket.arn]
    }

  }

  statement {
    sid    = "snowflake subscribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::893377700453:user/5dzc0000-s"]
    }

    actions = [
      "sns:Subscribe"
    ]

    resources = [
      aws_sns_topic.datalake_bucket_event_sns_topic.arn
    ]
  }
}
