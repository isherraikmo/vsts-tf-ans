resource "azurerm_resource_group" "aci-rg" {
  name     = "rdo-ado-agents"
  location = "UK South"
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.aci-rg.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "aci-sa" {
  name                = "rdoacisa${random_id.randomId.hex}"
  resource_group_name = "${azurerm_resource_group.aci-rg.name}"
  location            = "${azurerm_resource_group.aci-rg.location}"
  account_tier        = "Standard"

  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "aci-share" {
  name                 = "rdo-aci-vsts-share"
  resource_group_name  = "${azurerm_resource_group.aci-rg.name}"
  storage_account_name = "${azurerm_storage_account.aci-sa.name}"

  quota = 50
}

resource "azurerm_container_group" "aci-vsts" {
  name                = "rdo-aci-agent"
  location            = "${azurerm_resource_group.aci-rg.location}"
  resource_group_name = "${azurerm_resource_group.aci-rg.name}"
  ip_address_type     = "public"
  os_type             = "linux"


  container {
    name   = "rdo-vsts-agent"
    image  = "karanotts/dockervstsagent:sshd"
    cpu    = "0.5"
    memory = "1.5"
    ports  {
      port      = "22"
      protocol  = "TCP"
    }

    environment_variables {
      "AZP_URL"        = "${var.vsts-url}"
      "AZP_TOKEN"      = "${var.vsts-token}"
      "AZP_AGENT_NAME" = "${var.vsts-agent}"
      "AZP_POOL"       = "${var.vsts-pool}"
    }

    volume {
      name       = "logs"
      mount_path = "/aci/logs"
      read_only  = false
      share_name = "${azurerm_storage_share.aci-share.name}"

      storage_account_name = "${azurerm_storage_account.aci-sa.name}"
      storage_account_key  = "${azurerm_storage_account.aci-sa.primary_access_key}"
    }
  }

  tags {
    environment = "testing"
  }
}
