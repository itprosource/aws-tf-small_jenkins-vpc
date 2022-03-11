variable "name" {
  type = string
  description = "Name used to identify all resources."
  default = ""
}

variable "cidr" {
  type = string
  description = "CIDR block for entire VPC."
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  type = string
  description = "CIDR block for public subnet."
  default = "10.0.1.0/24"
}

variable "associate_public_ip_address" {
  type = bool
  description = "Option to map public IP to instance at launch."
  default = true
}

variable "ingress_http_allow" {
  type = list(string)
  description = "List of allowed IPs for HTTP access."
  default = []
}

variable "ingress_ssh_allow" {
  type = list(string)
  description = "List of allowed IPs for SSH access."
  default = []
}