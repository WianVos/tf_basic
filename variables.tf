# keys must be set in your environment and then passed to terraform using the -vars option
variable "aws_access_key" {
  default = ""
}

# keys must be set in your environment and then passed to terraform using the -vars option
variable "aws_secret_key" {
  default = ""
}

# we are using an european region ofcourse
variable "aws_region" {
  default = "eu-central-1"
}

# very open subnet :-)
variable "private_subnet_cidr" {
  default = "0.0.0.0/0"
}

#number of  servers
variable "basic_count" {
  default = 2
}

#consul servers to join
variable "consul_server_addr" {
  default = ""
}
