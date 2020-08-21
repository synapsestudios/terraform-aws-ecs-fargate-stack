provider "aws" {
  region  = "us-west-2"
  version = "~> 2.12"
}

module "ecs" {
  source            = "../../"
  name              = "someapp"
  database_name     = "someapp"
  database_username = "test_user"
  database_password = "Test123456"

  # TODO have this value pulled from global tfstate of networks to avoid overlap
  vpc_cidr = "10.0.0.0/20"

  tags = {
    Owner         = "SynapseStudios"
    Provisioner   = "terraform"
    ProvisionedBy = "james@synapsestudios.com"
    ProvisionedOn = "2020-01-16"
    DNSZone       = "someapp.com"
    BillTo        = "SomeClient"
  }
}
