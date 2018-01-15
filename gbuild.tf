provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_role" "codebuild_role" {
    name = "codebuild-role"
    assume_role_policy = <<ENDPOLICY
{
    "Version": "2012-10-17", 
    "Statement": [
        {
            "Effect": "Allow", 
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            }, 
            "Action": "sts:AssumeRole"
        }
    ]
}
ENDPOLICY
}

resource "aws_iam_policy" "codebuild_policy" {
    name = "codebuild-policy"
    path = "/service-role/"
    policy = <<ENDPOLICY
{
    "Version": "2012-10-17", 
    "Statement": [
        {
            "Effect": "Allow", 
            "Resource": [
                "*"
            ], 
            "Action": [
                "logs:CreateLogGroup", 
                "logs:CreateLogStream", 
                "logs:PutLogEvents", 
                "ecr:GetAuthorizationToken", 
                "ecr:InitiateLayerUpload", 
                "ecr:UploadLayerPart", 
                "ecr:CompleteLayerUpload", 
                "ecr:BatchCheckLayerAvailability", 
                "ecr:PutImage"
            ]
        }
    ]
}
ENDPOLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
    name = "codebuild-policy-attachment"
    policy_arn ="${aws_iam_policy.codebuild_policy.arn}"
    roles = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "buildtechnovangelistbuilder" {
    name = "buildtechnovangelistbuilder"
    description = "CodeBuild project to build technovangelist.com"
    build_timeout= "5"
    service_role="${aws_iam_role.codebuild_role.arn}"

    artifacts {
        type = "NO_ARTIFACTS"
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "jch254/dind-terraform-aws"
        type = "LINUX_CONTAINER"
        privileged_mode = true     # don't set this and you get errors on the install
    }

    source {
        type = "GITHUB"
        location = "https://github.com/technovangelist/technovangelist-build.git"
        buildspec = "builder-buildspec.yml"
    }
    provisioner "local-exec" {
        command = "aws codebuild create-webhook --project-name buildtechnovangelistbuilder"
    }

}

resource "aws_ecr_repository" "mattw-technovangelist-builder" {
  name = "mattw-technovangelist-builder"
}
