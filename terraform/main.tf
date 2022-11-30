resource "azurerm_resource_group" "ts_rg_we_dev" {
  name     = "ts-rg-we-dev"
  location = "West Europe"
}

resource "azurerm_network_security_group" "ts_nsg_we_dev_01" {
  name                = "ts-nsg-we-dev-01"
  location            = azurerm_resource_group.ts_rg_we_dev.location
  resource_group_name = azurerm_resource_group.ts_rg_we_dev.name
}

resource "azurerm_virtual_network" "ts_vnet_we_dev" {
  name                = "ts-vnet-we-dev"
  location            = azurerm_resource_group.ts_rg_we_dev.location
  resource_group_name = azurerm_resource_group.ts_rg_we_dev.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet" "ts_snet_we_dev_01" {
  name                 = "ts-snet-we-dev-01"
  resource_group_name  = azurerm_resource_group.ts_rg_we_dev.name
  virtual_network_name = azurerm_virtual_network.ts_vnet_we_dev.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "ts_snet_we_dev_02" {
  name                 = "ts-snet-we-dev-02"
  resource_group_name  = azurerm_resource_group.ts_rg_we_dev.name
  virtual_network_name = azurerm_virtual_network.ts_vnet_we_dev.name
  address_prefixes     = ["10.0.0.64/26"]
}

resource "azurerm_network_interface" "ts_nic_we_dev_01" {
  name                = "ts-nic-we-dev-01"
  location            = azurerm_resource_group.ts_rg_we_dev.location
  resource_group_name = azurerm_resource_group.ts_rg_we_dev.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.ts_snet_we_dev_01.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "ts_vm_we_dev_01" {
  name                  = "ts-vm-we-dev-01"
  location              = azurerm_resource_group.ts_rg_we_dev.location
  resource_group_name   = azurerm_resource_group.ts_rg_we_dev.name
  network_interface_ids = [azurerm_network_interface.ts_nic_we_dev_01.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Development"
  }
}

provider "azurerm" {
   features {}
}