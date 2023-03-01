
# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "azuredevops" {
  name     = var.resourcegroup
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "azuredevopsnetwork_win" {
  name                = "AzureDevOpsVnet_Win"
  address_space       = ["10.200.0.0/16"]
  location            = var.location
  resource_group_name = "${azurerm_resource_group.azuredevops.name}"
}

# Create subnet
resource "azurerm_subnet" "azuredevopssubnet_win" {
  name                 = "AzureDevopsSubnet_Win"
  resource_group_name  = "${azurerm_resource_group.azuredevops.name}"
  virtual_network_name = "${azurerm_virtual_network.azuredevopsnetwork_win.name}"
  address_prefixes       = ["10.200.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "azuredevopspublicip_win" {
  name                = "AzureDevOpsPublicIP_Win"
  location            = var.location
  resource_group_name = "${azurerm_resource_group.azuredevops.name}"
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "azuredevopsnsg" {
  name                = "AzureDevOpsNetworkSecurityGroup"
  location            = var.location
  resource_group_name = "${azurerm_resource_group.azuredevops.name}"
}

# Create network interface
resource "azurerm_network_interface" "azuredevopsnic_win" {
  name                      = "AzureDevOpsNIC_win"
  location                  = var.location
  resource_group_name       = "${azurerm_resource_group.azuredevops.name}"

  ip_configuration {
    name                          = "AzureDevOpsNicConfiguration_Win"
    subnet_id                     = "${azurerm_subnet.azuredevopssubnet_win.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.azuredevopspublicip_win.id}"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.azuredevops.name}"
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "azuredevopsstorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.azuredevops.name}"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_virtual_machine" "azuredevopsvm_win" {
  name                  = "AzureDevOps"
  location              = var.location
  resource_group_name   = "${azurerm_resource_group.azuredevops.name}"
  network_interface_ids = ["${azurerm_network_interface.azuredevopsnic_win.id}"]
  vm_size               = "${var.size}"
  delete_os_disk_on_termination = "true"
  delete_data_disks_on_termination = "true"

  storage_os_disk {
    name              = "AzureDevOpsOsDiskWin"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.azuredevopsstorageaccount.primary_blob_endpoint}"
  }
}


resource "azurerm_virtual_machine_extension" "azuredevopsvmex" {
  name                 = "AzureDevOpsAgent"
  virtual_machine_id   = "${azurerm_virtual_machine.azuredevopsvm_win.id}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
  "fileUris": ["https://tfstraccnt.blob.core.windows.net/tf-scripts/devops_win.ps1?sp=r&st=2023-03-01T07:12:19Z&se=2023-04-30T15:12:19Z&spr=https&sv=2021-06-08&sr=b&sig=pRrf6EG82XzGAGyH1%2BDGOTxyK9o9n3b5iwbpkhPHYwE%3D"],
  "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ./devops_win.ps1 -URL ${var.url} -PAT ${var.pat} -POOL ${var.pool} -AGENT ${var.agent}",
  "timestamp" : "12"
  }
SETTINGS


}

