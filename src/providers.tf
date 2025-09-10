terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.5"
}

provider "yandex" {
  # token     = var.token
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  shared_credentials_file  = "/home/vm30/.aws/credentials"
#  zone                     = var.default_zone
  service_account_key_file = file("~/.authorized_key.json")
}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = var.key_name
  description       = var.key_desc
  default_algorithm = "AES_256"
  rotation_period   = "168h"
}

resource "yandex_storage_bucket" "my-bucket-dog" {
  bucket = "my-bucket-dog"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  server_side_encryption_configuration {
    rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = yandex_kms_symmetric_key.key-a.id
      sse_algorithm     = "aws:kms"
    }
  }
  }
  
}

resource "yandex_storage_object" "image" {
  bucket = yandex_storage_bucket.my-bucket-dog.bucket
  key    = "image.jpeg"
  source = "/home/vm30/homework/22.3/terraform_2/image/image.jpeg"
  acl = "public-read"
  tags = {
    test = "value"
  }
}
