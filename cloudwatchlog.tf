######################################################################
# 1. Create an IAM Role for the EC2 Instance AssumeRole
######################################################################
resource "aws_iam_role" "EC2CloudWatchLogRole" {
  name        = "EC2CloudWatchLogRole"
  description = "EC2 Instance to assume role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

######################################################################
# 3. Attach the Policy to the IAM Role
######################################################################
resource "aws_iam_role_policy_attachment" "attach_CloudWatchLogPolicy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"])
  role       = aws_iam_role.EC2CloudWatchLogRole.name
  policy_arn = each.value
}

######################################################################
# 4. CloudWatch Log group to 
######################################################################
resource "aws_cloudwatch_log_group" "demo_log_group" {
  name              = "/cloudwatch/logs"
  retention_in_days = 1 # tells us how long we want to keep log events in the specified log group.
}

######################################################################
# 5. CloudWatch Agent Configuration
######################################################################
data "template_file" "cloudwatch_agent_config" {
  template = file("${path.module}/cloudwatch_agent_config.json.tpl")

  vars = {
    log_group_name = aws_cloudwatch_log_group.demo_log_group.name
  }
}

resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name  = "/cloudwatch-agent/config"
  type  = "String"
  value = data.template_file.cloudwatch_agent_config.rendered
}

resource "aws_iam_instance_profile" "cloudwatch_agent_profile" {
  name = "CloudWatchAgentProfile"
  role = aws_iam_role.EC2CloudWatchLogRole.name
}