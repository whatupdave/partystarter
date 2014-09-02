variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "subdomain" {
  default = "mc"
}
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
variable "s3_path" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
provider "dnsimple" {
    token = "${var.dnsimple_token}"
    email = "${var.dnsimple_email}"
}

resource "digitalocean_droplet" "node" {
  image = "docker"
  name = "node"
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
      "docker run -d -e ACCESS_KEY=${var.aws_access_key} -e SECRET_KEY=${var.aws_secret_key} --name data whatupdave/s3-volume ${var.s3_path}",
      "while ! docker logs data | grep 'ready'; do sleep 1; done",
      "docker run -id -p 25565:25565 --volumes-from data --name minecraft whatupdave/partycloud-minecraft"
    ]
  }
}

resource "dnsimple_record" "subdomain" {
  domain = "${var.domain}"
  name = "${var.subdomain}"
  value = "${digitalocean_droplet.node.ipv4_address}"
  type = "A"
  ttl = 60
}

output "server" {
  value = "${var.subdomain}.${var.domain}"
}
