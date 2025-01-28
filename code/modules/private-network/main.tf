data "azurerm_resource_group" "main" {
  name = var.resource_group_name
  
}

locals {
  dns_record = var.request_pe ? azurerm_private_endpoint.private_endpoint[0].private_service_connection[0].private_ip_address : var.static_ip_address
}

resource "azurerm_private_endpoint" "private_endpoint" {
  count = var.request_pe ? 1 : 0
  name                = "${replace(var.prefix, "-", "")}-${var.resource_type}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${replace(var.prefix, "-", "")}-${var.resource_type}-psc"
    private_connection_resource_id = var.resource_id
    is_manual_connection           = false
    subresource_names              = [var.subresource_name]
  }
}

resource "azurerm_private_dns_zone" "app_config_dns" {
  name                = "privatelink.${var.resource_type}.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_config_dns_link" {
  name                  = "${replace(var.prefix, "-", "")}-${var.resource_type}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.app_config_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "app_config_a_record" {
  name                = "${replace(var.prefix, "-", "")}-${var.resource_type}"
  zone_name           = azurerm_private_dns_zone.app_config_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [local.dns_record]
}