# terraform-aws-bitcoind
Bitcoin core daemon spun up on EC2 instance in AWS. 

### Recommended: If you want to use this in a public subnet, please take extra time to configure appropriate ufw/iptables.
### Example Usage:
```
module "bitcoind" {
  source = "github.com/miketwenty1/terraform-aws-bitcoind"

  region                = "us-east-1"
  subnet_id             = data.aws_subnet.private.id
  ssh_key_name          = "bitcoin_ssh_key_example"
  sg_for_ssh_access_id  = data.aws_security_group.vpn.id
  bitcoin_version       = var.bitcoin_version
  instance_size         = var.instance_size
  alias                 = var.alias
  rpc_access_cidr       = var.rpc_access_cidr
}
```

### Notable parameters: for a full list of configurable parameters please see variables.tf
- `subnet_id` if using public subnet also set "enable_external_ip" to true, if using a private subnet (recommended) keep set to false.
- `enable_external_ip` set to true if you want an external IP. If not set to true, you will need to use a jump box / vpn or other method to access your node.
- `sg_for_ssh_access_id` should be used if you want to setup vpn or jumpbox access.
- `rpc_access_cidr` recommended to set this to specific /32 cidr for your IP.
- `alias` useful name to help avoid conflicts with named resources
- `bitcoin_version` uses a tagged version of bitcoind in github.com/bitcoin/bitcoin

### Mandatory parameters:
- `subnet_id` (valid subnet id inside VPC with appropriate tag)
- `ssh_key_name` (ssh key)
- `region` (aws region)
- `rpc_access_cidr` (cidr block ex: 0.0.0.0/0 is open to the internet, 1.2.3.4/32 is open to only ip 1.2.3.4)

### Dependencies: 
Have a VPC tagged with "key" `bitcoin_terraform` and "Value" `enabled`, This module will look to deploy the bitcoin node in this VPC.
`ssh_key_name` needs to be created before running this module, and specified by name.

### Cloudwatch Agent:
The cloudwatch agents are installed through SSM, if you want to setup custom, cloudwatch alarms this is outside of the scope of the module. Happy to accept PR's.

### RPC and RMQ Access
Access sg's are created and sent to outputs, assign sg's these to resources that need access to RPC or ZMQ