module dir {
    source = "hashicorp/dir/template"
    version = "1.0.2"
    base_dir = "./website"
}

resource "aws_s3_bucket" "crc_s3_bucket" {
    bucket = "crcbucketterraform"
    tags = {
        Name = "crc bucket"
        description = "cloud resume challenge bucket - Terraform provisioned"
    }
}

resource "aws_s3_bucket_acl" "crc_bucket_acl"{
    bucket = aws_s3_bucket.crc_s3_bucket.bucket
    acl = "private"
}

resource "aws_s3_object" "crc_objects" {
    for_each = module.dir.files
    bucket = resource.aws_s3_bucket.crc_s3_bucket.bucket
    key = each.key
    content_type = each.value.content_type
    # source = "./website/${each.value}"
    source = each.value.source_path
    # etag = filemd5("./website/${each.value}")
    etag = each.value.digests.md5
}

resource "aws_s3_bucket_website_configuration" "crc_s3_website_config"{
    bucket = aws_s3_bucket.crc_s3_bucket.bucket

    index_document {
      suffix = "index.html"
    }
}

resource "aws_s3_bucket_policy" "crc_s3_policy"{
    bucket = aws_s3_bucket.crc_s3_bucket.bucket
    policy = file("./iam_policies_module/policy_documents/bucket_policy.json")
}

output "bucket_regional_domain_name"{
    value = aws_s3_bucket.crc_s3_bucket.bucket_regional_domain_name
}

output "s3_website_endpoint"{
    value = aws_s3_bucket.crc_s3_bucket.website_endpoint
}