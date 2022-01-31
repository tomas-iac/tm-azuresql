variable "subnetId" {
  type = string
}

variable "serverName" {
  type = string
}

variable "dbName" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "location" {
  type = string
}

variable "privateDnsZoneId" {
  type    = string
  default = null
}

variable "adminUsername" {
  type = string
}

variable "adminPassword" {
  type      = string
  sensitive = true
}

variable "sku" {
  type    = string
  default = "GP_Gen5_2"
}

variable "logAnalyticsWorkspaceId" {
  type    = string
  default = null
}

variable "enableMonitoring" {
  type    = bool
  default = false
}

