# Creates S3 bucket for nwp data

# make sure all public access is blocked
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "s3-nwp-block-public-access" {
  bucket = aws_s3_bucket.s3-nwp-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "s3-nwp-bucket" {
  bucket = "nowcasting-nwp-${var.environment}"

  tags = {
    Name        = "${var.environment}-s3"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "nwp-bucket-ownership-controls" {
  bucket = aws_s3_bucket.s3-nwp-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "nwp-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.nwp-bucket-ownership-controls]

  bucket = aws_s3_bucket.s3-nwp-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "nwp-bucket-lifecycle" {
  bucket = aws_s3_bucket.s3-nwp-bucket.id

  rule {
    id      = "remove_old_files"
    enabled = true
    filter {
      prefix = "data/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }

  rule {
    id      = "remove_old_raw_files"
    enabled = true
    filter {
      prefix = "raw/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }

  rule {
    id      = "remove_old_files_national"
    enabled = true
    filter {
      prefix = "data-national/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }

  rule {
    id      = "remove_old_raw_files_national"
    enabled = true
    filter {
      prefix = "raw-national/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }
}


# get s3 bucket
# This means this bucket is not destroyed, we are just referencing it
data "aws_s3_bucket" "s3-ml" {
  bucket = "nowcasting-ml-models-${var.environment}"
}

# Creates S3 bucket for satellite data

# make sure all public access is blocked
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "s3-sat-block-public-access" {
  bucket = aws_s3_bucket.s3-sat-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "s3-sat-bucket" {
  bucket = "nowcasting-sat-${var.environment}"

  tags = {
    Name        = "${var.environment}-s3"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "sat-bucket-ownership-controls" {
  bucket = aws_s3_bucket.s3-sat-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "sat-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.sat-bucket-ownership-controls]

  bucket = aws_s3_bucket.s3-sat-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "sat-bucket-lifecycle" {
  bucket = aws_s3_bucket.s3-sat-bucket.id

  rule {
    id      = "remove_old_files"
    enabled = true
    filter {
      prefix = "data/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }

  rule {
    id      = "remove_old_raw_files"
    enabled = true
    filter {
      prefix = "raw/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }
}
