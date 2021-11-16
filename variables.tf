variable "env" {
  type    = string
  default = "default"
}

variable "alias" {
  type    = string
  default = "default"
}

locals {
  common_tags = {
    module  = "bitcoind"
    creator = "terraform"
    env     = var.env
  }
}
locals {
  ubuntu20_04 = {
    us-east-1 = "ami-0885b1f6bd170450c"
    us-east-2 = "ami-0a91cd140a1fc148a"
    us-west-1 = "ami-00831fc7c1e3ddc60"
    us-west-2 = "ami-07dd19a7900a1f049"
    # Add your region / ami here 
  }
}

# https://github.com/bitcoin-core/gitian.sigs for good hashes of builds for the bitcoin-VERSION-x86_64-linux-gnu.tar.gz
variable "gitian_hash" {
  type    = map(string)
  default = {
    v0-20-1 = "376194f06596ecfa40331167c39bc70c355f960280bd2a645fdbf18f66527397"
    v0-21-0 = "da7766775e3f9c98d7a9145429f2be8297c2672fe5b118fd3dc2411fb48e0032"
    v0-21-1 = "366eb44a7a0aa5bd342deea215ec19a184a11f2ca22220304ebb20b9c8917e2b"
    v22-0   = "59ebd25dd82a51638b7a6bb914586201e67db67b919b2a1ff08925a7936d1b16"
  }
}

variable "gitian_pgp_key" {
  type = string
  default = "01EA5486DE18A882D4C2684590C8019E36C2E964" #laanwj@gmail.com
}
variable "az_letter" {
  type    = string
  default = "a"
}

variable "root_volume_size" {
  type    = number
  default = 30
}
variable "bitcoin_volume_size" {
  type    = number
  default = 800
}

variable "rpc_user" {
  type      = string
  default   = "bitcoiner"
  sensitive = true
}

variable "instance_size" {
  type    = string
  default = "t3.medium"
}

variable "bitcoin_version" {
  type    = string
  default = "22.0"
}

# if blank there is no rule made for ssh with a cidr range
variable "cidr_block_ssh_access_rule" {
  type    = string
  default = ""
}

# if blank no rule is made for ssh sourced access to another sg 
variable "sg_for_ssh_access_id" { 
  type    = string
  default = ""
}


variable "subnet_id" {
  type = string
}
variable "ssh_key_name" {
  type = string
}


variable "region" {
  type = string
}

variable "rpc_access_cidr" {
  type = string
}

variable "enable_external_ip" {
  type    = bool
  default = false
}