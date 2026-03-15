resource "aws_iam_role" "ec2" {
  name = "ai-env-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock" {
  name = "bedrock-access"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel",
          "bedrock:ApplyGuardrail",
          "bedrock:InvokeAgent",
          "bedrock:RetrieveAndGenerate",
          "bedrock:Retrieve",
          "bedrock:GetInferenceProfile",
          "bedrock:ListInferenceProfiles"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_params" {
  name = "ssm-parameter-access"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:PutParameter"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/ai-env/*"
      }
    ]
  })
}

# Attach SSM managed policy for Session Manager (backup access if Tailscale fails)
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ai-env-ec2-profile"
  role = aws_iam_role.ec2.name
}
