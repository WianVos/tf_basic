output "public_dns" {
  value = ["${aws_instance.basic.*.public_dns}"]
}
