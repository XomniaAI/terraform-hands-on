output "website_url" {
  description = "Open this in your browser."
  value       = azurerm_storage_account.site.primary_web_endpoint
}
