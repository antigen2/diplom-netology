# Переменная окружения TF_VAR_yc_token
variable "yc_token" {
  type = string
}

# Переменная окружения TF_VAR_yc_cloud_id
variable "yc_cloud_id" {
  type = string
}

# Переменная окружения TF_VAR_yc_folder_id
variable "yc_folder_id" {
  type = string
}

# Переменная окружения TF_VAR_yc_sa_id
variable "yc_sa_id" {
  type = string
}

variable "yc_zone" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

variable "private_ip" {
  type = list(list(string))
  default = [
    ["192.168.10.0/24"],
    ["192.168.20.0/24"],
    ["192.168.30.0/24"]
  ]
}

variable "ssh_key_pub" {
  default = "~/.ssh/id_ed25519.pub"
}

locals {
  res = {
    cores = {
      stage = 4
      prod  = 8
    }
    memory = {
      stage = 4
      prod  = 8
    }
  }
}
