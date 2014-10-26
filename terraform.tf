variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "do_token" {}
variable "do_region" {
  default = "sfo1"
}
variable "do_size" {
  default = "1gb"
}
variable "domain" {}
variable "dnsimple_token" {}
variable "dnsimple_email" {}
variable "key_file" {
  default = "~/.ssh/id_rsa"
}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
provider "dnsimple" {
    token = "${var.dnsimple_token}"
    email = "${var.dnsimple_email}"
}

variable "vanilla_s3_path" {}
variable "vanilla_subdomain" {
  default = "vanilla"
}

variable "tekkit_s3_path" {}
variable "tekkit_subdomain" {
  default = "tekkit"
}

# --- Vanilla server

# resource "digitalocean_droplet" "vanilla" {
#   image = "docker"
#   name = "vanilla"
#   region = "${var.do_region}"
#   size = "${var.do_size}"
#   ssh_keys = ["${var.ssh_fingerprint}"]
#
#   connection {
#     user = "root"
#     type = "ssh"
#     key_file = "${var.key_file}"
#     timeout = "2m"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "docker run -d -e ACCESS_KEY=${var.aws_access_key} -e SECRET_KEY=${var.aws_secret_key} --name data whatupdave/s3-volume ${var.vanilla_s3_path}",
#       "while ! docker logs data | grep 'ready'; do sleep 1; done",
#       "docker run -id -p 25565:25565 --volumes-from data --name minecraft whatupdave/partycloud-minecraft"
#     ]
#   }
# }
# resource "dnsimple_record" "vanilla_subdomain" {
#   domain = "${var.domain}"
#   name = "${var.vanilla_subdomain}"
#   value = "${digitalocean_droplet.vanilla.ipv4_address}"
#   type = "A"
#   ttl = 60
# }

# --- Tekkit server

resource "digitalocean_droplet" "tekkit" {
  image = "docker"
  name = "tekkit"
  region = "${var.do_region}"
  size = "${var.do_size}"
  ssh_keys = ["${var.ssh_fingerprint}"]

  connection {
    user = "root"
    type = "ssh"
    key_file = "${var.key_file}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "docker run -d --restart=always -e ACCESS_KEY=${var.aws_access_key} -e SECRET_KEY=${var.aws_secret_key} --name data whatupdave/s3-volume ${var.tekkit_s3_path}",
      "while ! docker logs data | grep 'ready'; do sleep 1; done",
      "docker run -id -p 25565:25565 --restart=always --volumes-from data --name minecraft whatupdave/partycloud-minecraft:tekkit"
    ]
  }
}
resource "dnsimple_record" "tekkit_subdomain" {
  domain = "${var.domain}"
  name = "${var.tekkit_subdomain}"
  value = "${digitalocean_droplet.tekkit.ipv4_address}"
  type = "A"
  ttl = 30
}
