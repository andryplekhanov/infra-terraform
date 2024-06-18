locals {
  zone = "ru-central1-b"
}

# Создание сервисного акканута для Terraform
resource "yandex_iam_service_account" "sa-tf" {
  name        = "gitlab-terraform-sa"
  description = "Service account for Terraform in Gitlab"
}

# Назначение роли сервисному аккаунту - admin
resource "yandex_resourcemanager_folder_iam_member" "sa_terraform_admin" {
  folder_id = data.yandex_client_config.client.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-tf.id}"
}

# Создание авторизованного ключа доступа
resource "yandex_iam_service_account_key" "sa-auth-key" {
  service_account_id = "${yandex_iam_service_account.sa-tf.id}"
  description        = "Key for service account"
  key_algorithm      = "RSA_2048"
}

# Создание файла .key.json с ключом доступа для Terraform
resource "local_file" "key" {
  content = <<EOH
  {
    "id": "${yandex_iam_service_account_key.sa-auth-key.id}",
    "service_account_id": "${yandex_iam_service_account.sa-tf.id}",
    "created_at": "${yandex_iam_service_account_key.sa-auth-key.created_at}",
    "key_algorithm": "${yandex_iam_service_account_key.sa-auth-key.key_algorithm}",
    "public_key": ${jsonencode(yandex_iam_service_account_key.sa-auth-key.public_key)},
    "private_key": ${jsonencode(yandex_iam_service_account_key.sa-auth-key.private_key)}
  }
  EOH
  filename = ".key.json"
}

# Создание VPC для GitLab
resource "yandex_vpc_network" "gitlab" {
  name = "gitlab-vpc"
}

# Создание подсети
resource "yandex_vpc_subnet" "gitlab" {
  name           = "gitlab-subnet"
  zone           = local.zone
  network_id     = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

# Получение актуального image_id
data "yandex_compute_image" "gitlab" {
  family = "ubuntu-2004-lts"
}

# Создание загрузочного диска для VM
resource "yandex_compute_disk" "runner" {
  name     = "gitlab-runner-disk"
  zone     = local.zone
  image_id = data.yandex_compute_image.gitlab.image_id
  size     = "15"

  lifecycle {
    ignore_changes = [image_id]
  }
}

# Создание VM для GitLab Runner
resource "yandex_compute_instance" "runner" {
  name                      = "gitlab-runner"
  zone                      = local.zone
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.runner.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.gitlab.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = file("cloud-init.yaml")
  }
}