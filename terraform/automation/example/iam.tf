resource "aws_iam_role" "ec2_iam_role" {
  name = "${format("%s-%s-monitoring-iam-role", var.name, lookup(var.tags, "Environment"))}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${merge(map("Name", format("%s-%s-monitoring-iam-role", var.name, lookup(var.tags, "Environment"))), var.tags)}"
}


resource "aws_iam_instance_profile" "ec2_monitoring_profile" {
  name = "ec2-monitoring-profile"
  role = "${aws_iam_role.ec2_iam_role.name}"
}

resource "aws_iam_role_policy" "monitoring_policy" {
  name = "monitoring-policy"
  role = "${aws_iam_role.ec2_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
