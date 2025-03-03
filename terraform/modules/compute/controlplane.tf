# Create IAM Role
resource "aws_iam_role" "eks_master_role" {
  name = "${var.eks_name}-ControlPlane-iam-role-${var.env}"
  tags = {
    "Name"          = "${var.eks_name}-ControlPlane-iam-role-${var.env}"
    "Managed-by"    = "Terraform"
    "Product"       = "${var.project}"
    "Environment"   = "${var.env}"
  }
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}


resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-ec2-describe-policy" {
  policy_arn = aws_iam_policy.ec2-describe-policy.arn
  role       = aws_iam_role.eks_master_role.name
}


resource "aws_iam_policy" "ec2-describe-policy" {
  name        = "${var.eks_name}-ec2-describe-policy-${var.env}"
  tags = {
    "Name" = "${var.eks_name}-ec2-describe-policy-${var.env}"
    "Managed-by" = "Terraform"
    "Product"  = "${var.project}"
    "Environment" = "${var.env}"
  }
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInternetGateways"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
})
}



######### KMS KEY #######

resource "aws_kms_key" "eks-key" {

  description              = "KMS key for EKS cluster"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = false
  multi_region             = true
  tags = {
    "Name"         = "${var.eks_name}-KMS-key-${var.env}"
    "Managed by"   = "Terraform"
    "Product"      = "${var.project}"
    "Environment " = "${var.env}"
    "Alias"        = "${var.eks_name}-KMS-key-${var.env}"
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.eks_name}-master-key-${var.env}"
  target_key_id = aws_kms_key.eks-key.key_id
}



#### EKS RESOURCE ######

resource "aws_eks_cluster" "eks_cluster" {
    name = "${var.eks_name}-${var.env}"
    role_arn = aws_iam_role.eks_master_role.arn
    version = var.k8s-version
    vpc_config {
      subnet_ids = var.private_subnet_ids
      endpoint_private_access = var.endpoint_private_access
      endpoint_public_access = var.endpoint_public_access
      security_group_ids = [data.aws_security_group.sg.id]
    }
    kubernetes_network_config {
     service_ipv4_cidr = var.kubernetes_network_config-sevice-ipv4-cidr
    }


    encryption_config {
      resources = ["secrets"]
      provider {
        key_arn = aws_kms_key.eks-key.arn
      }

    }

  enabled_cluster_log_types = [ "api" , "audit" , "authenticator" , "controllerManager" , "scheduler" ]
  depends_on = [
    aws_kms_key.eks-key,
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy ,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly ,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.eks-ec2-describe-policy ## this is not managed policy
  ]
  tags = {
    "Name" = "${var.eks_name}-${var.env}"
    "Managed-by" = "Terraform"
    "Product"  = "${var.project}"
    "Environment" = "${var.env}"
  }


}



####### BASTION HOST - JUMP BOX #########

resource "aws_instance" "bastion" {
  ami             = "ami-05b10e08d247fb927"  # Replace with your AMI
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.public_subnets[0].id
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id  # Reference your VPC ID

  # Allow SSH from your trusted IP (modify as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_cidr  # Replace with your IP
  }

  # Allow outbound access to private instances (inside VPC)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}




