#Specify Resource Group 
variable "resourcegroup" {
  type    = string
  description = "Specify the resource group where the VM should be created"
}

variable "location" {
  type    = string
  description = "Specify the location where the resources should be created, e.g. westeurope"
}

#Replace [Organization] https://dev.azure.com/[Organization]/_usersSettings/tokens
variable "url" {
  type    = string
  description = "Specify the Azure DevOps url e.g. https://dev.azure.com/mmelcher"
}

#Create via https://dev.azure.com/[Organization]/_usersSettings/tokens
variable "pat" {
  type    = string
  description = "Provide a Personal Access Token (PAT) for Azure DevOps"
}

#The build agent pool. Create it via https://dev.azure.com/[Organization]/_settings/agentpools?poolId=8&_a=agents
variable "pool" {
  type    = string
  description = "Specify the name of the agent pool - must exist before"
}

#The name of the agent
variable "agent" {
  type    = string
  description = "Specify the name of the agent"
}

variable "size" {
  type    = string
  description = "Specify the size of the VM"
}

variable "hostname" {
  type    = string
  description = "Specify the hostname of the VM"
}

variable "admin_username" {
  type    = string
  description = "Specify the admin username of the VM"
}

variable "admin_password" {
  type    = string
  description = "Specify the admin username of the VM"
}

#Specify PS Script to executue
variable "psfile" {
  type    = string
  description = "Specify the resource group where the VM should be created"
}
