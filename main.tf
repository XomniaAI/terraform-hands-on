# Names must be unique: storage account names across all of Azure, resource group names across
# the course subscription. So we add 6 random characters. The state file remembers them, so they
# stay the same on every run.
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Your own resource group: a folder for everything below. `terraform destroy` removes it too.
resource "azurerm_resource_group" "mine" {
  name     = "rg-tf-${var.your_name}-${random_string.suffix.result}"
  location = "westeurope"

  tags = {
    owner = var.your_name
  }
}

resource "azurerm_storage_account" "site" {
  name                     = "st${var.your_name}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.mine.name
  location                 = azurerm_resource_group.mine.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  shared_access_key_enabled = false # no keys: Terraform logs in with your Azure account

  tags = {
    owner = var.your_name
  }
}

# Turns on web hosting. Azure creates a container called $web: what's in it is your website.
resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.site.id
  index_document     = "index.html"
}

resource "azurerm_storage_blob" "index" {
  name                 = "index.html"
  storage_container_id = "${azurerm_storage_account_static_website.site.storage_account_id}/blobServices/default/containers/$web"
  type                 = "Block"
  content_type         = "text/html" # so the browser shows the page instead of downloading it

  source_content = <<-HTML
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><title>Hello from ${var.your_name}</title></head>
      <body style="background:${var.colour}; color:white; font:3rem sans-serif; text-align:center; padding-top:20vh">
        Hello from ${var.your_name}!<br>
        <small>Deployed with Terraform</small>
      </body>
    </html>
  HTML
}
