output "PublicIPVPN" {
  descriptio = "PublicIP"
  value = azurerm_public_ip.PublicIPForVPN.id
}
