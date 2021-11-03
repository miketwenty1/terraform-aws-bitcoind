data "template_file" "bitcoin_conf" {
  template = file("${path.module}/bitcoin.conf.tpl")
  vars = {
    RPCUSER         = var.rpc_user
    RPCPASS         = random_password.rpc.result
    VERSION         = var.bitcoin_version
    RPC_ACCESS_CIDR = var.rpc_access_cidr
  }
}

data "template_file" "shell-script" {
  template = file("${path.module}/cloud-init.sh")

  vars = {
    VERSION        = var.bitcoin_version
    GITIAN_HASH    = lookup(var.gitian_hash, "v${replace(var.bitcoin_version, ".", "-")}", "this version not defined")
    GITIAN_PGP_KEY = var.gitian_pgp_key
    REGION         = var.region
  }
}

data "template_cloudinit_config" "cloud-init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "bitcoind_conf.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.bitcoin_conf.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}
