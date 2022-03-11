provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../"

  name = "jenkins"
  cidr = "10.0.0.0/16"
  public_subnet   = "10.0.1.0/24"
  associate_public_ip_address = true
  ingress_http_allow = ["99.101.44.120/32"]
  ingress_ssh_allow = ["99.101.44.120/32"]

}