# Past your backend here:

#terraform {
#  backend "s3" {
#    region         = "ru-central1"
#    bucket         = "andreiplekhanov6nw2crq163"
#    key            = "terraform.tfstate"
#
#    dynamodb_table = "state-lock-table"
#
#    endpoints = {
#      s3       = "https://storage.yandexcloud.net",
#      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gdtu6fru13qselq36d/etnmbvjc6bhdmic3h1dk"
#    }
#
#    skip_credentials_validation = true
#    skip_region_validation      = true
#    skip_requesting_account_id  = true
#    skip_s3_checksum            = true
#  }
#}