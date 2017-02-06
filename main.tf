#compose variables

#Initialize the AWS provider
#
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# retrieve the ami info from aws ..
# this makes the image selection a little more robust
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# configure an aws keypair to use
# keys are used from the ssh_keys folder located in the folder where this .tf file resides in
resource "aws_key_pair" "basic" {
  key_name   = "basic"
  public_key = "${file("./ssh_keys/rsa.pub")}"
}

# the basic security group for our deathstar consul hosts

resource "aws_security_group" "basic" {
  name        = "basic"
  description = "basic sec profile"

  // These are for internal traffic
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  // These are for maintenance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "consul_agent_config" {
  template = "${file("environments/basic/templates/consul_agent.json")}"

  vars {
    consul_server_addr = "${var.consul_server_addr}"
  }
}

# this bit creates the instance
# pretty straight forward stuff

resource "aws_instance" "basic" {
  instance_type = "t2.small"

  tags {
    name = "basic"
  }

  ami               = "${data.aws_ami.ubuntu.id}"
  count             = "${var.basic_count}"
  key_name          = "${aws_key_pair.basic.id}"
  security_groups   = ["${aws_security_group.basic.name}"]
  source_dest_check = false

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("ssh_keys/rsa")}"
    timeout     = "1m"
    agent       = false
  }

  tags {
    Name = "basic-${count.index}"
  }

  #
  provisioner "file" {
    source      = "./environments/basic/files/consul.service"
    destination = "/tmp/consul.service"
  }

  provisioner "file" {
    content     = "${data.template_file.consul_agent_config.rendered}"
    destination = "/tmp/consul_agent.json"
  }

  provisioner "remote-exec" {
    scripts = [
      "./environments/basic/scripts/consul_install.sh",
      "./environments/basic/scripts/consul_service.sh",
    ]
  }

  provisioner "file" {
    source      = "./ssh_keys/rsa"
    destination = "/home/ubuntu/.ssh/rsa"
  }
}
