variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "do_token" {}
variable "key_file" {
  default = "~/.ssh/id_rsa"
}
variable "s3_path" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "node" {
  image = "docker"
  name = "node"
  region = "sfo1"
  size = "1gb"
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

output "server" {
  value = "${digitalocean_droplet.node.ipv4_address}"
}
