resource "yandex_vpc_network" "gitlab" {
  name = "yc-test-gitlab-vpc"
}

resource "yandex_vpc_subnet" "gitlab-subnet-a" {
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.gitlab.id}"
}

#resource "yandex_vpc_subnet" "gitlab-subnet-b" {
#  v4_cidr_blocks = ["10.2.0.0/16"]
#  zone           = "ru-central1-b"
#  network_id     = "${yandex_vpc_network.gitlab.id}"
#}

