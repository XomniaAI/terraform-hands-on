# Terraform hands-on: your own website on Azure

You deploy a small web page to Azure with Terraform, from your own laptop. It shows your name, in your colour. Then you change it, write your own code, break the state on purpose, and remove everything again.

**~2 hours. Do it from top to bottom.**

| Section | What you do | Time |
|---|---|---|
| [Setup](#setup) | install, log in, deploy your page | 15 min |
| [Part 1 · Change things](#part-1--change-things) | read a plan: create, change, replace, drift | 35 min |
| [Part 2 · Write your own code](#part-2--write-your-own-code) | new resources, `for_each`, `moved`, `prevent_destroy` | 30 min |
| [Part 3 · Work with state](#part-3--work-with-state) | the lock, lost state, `removed`, `import` | 35 min |
| [The end](#12--remove-everything--5-min) | remove everything | 5 min |

Running out of time? Jump to [exercise 12](#12--remove-everything--5-min) whenever you want. It works from any point.

What Terraform creates for you:

| Resource | What it is |
|---|---|
| A resource group, `rg-tf-<your name>-<6 random characters>` | a folder in Azure that holds everything below |
| A storage account | Azure's file storage: the "bucket" from the course |
| Static website hosting | lets the storage account serve web pages |
| `index.html` | your page |
| 6 random characters | so your names never clash with another trainee's |

---

## Setup

### A · Install · 5–10 min

You need Terraform **1.16** and the Azure CLI.

**macOS**
```sh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform azure-cli
```

**Windows** (PowerShell, then open a new terminal)
```powershell
winget install Hashicorp.Terraform
winget install Microsoft.AzureCLI
```

Check:
```sh
terraform version    # expect: Terraform v1.16.x
az version
```

### B · Log in to Azure · 2 min

```sh
az login
```

A browser opens. Log in with the account your trainer gave access to. If it asks you to pick a subscription, pick **training**.

### C · Get the code · 1 min

```sh
git clone https://github.com/JiDarwish/terraform-hands-on.git
cd terraform-hands-on
```

### D · Put in your name · 1 min

Open `terraform.tfvars` and change `change-me` to your name: 2 to 12 lowercase letters, no spaces.

```hcl
your_name = "anna"
```

### E · Deploy · 5 min

```sh
terraform init       # downloads the Azure plugin. Once per folder.
terraform plan       # shows what Terraform WOULD do. Read it: expect 5 to add.
terraform apply      # does it. Shows the plan again, then answer: yes
terraform output     # prints your website_url
```

Open the `website_url` in your browser.

**The first 1–2 minutes you may see `404 WebsiteDisabled`.** Azure is still switching your website on. Wait 2 minutes, then refresh.

Your page is live. Now the exercises.

---

## The exercises

Each exercise has the same shape: **do** something, **run** a command, **expect** what you'll see, and **why** it matters.

**Look things up** in the [azurerm provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs): every Azure resource Terraform knows, with all its settings. Search a resource name, for example `azurerm_storage_account`. Each page has:

| Section | Tells you |
|---|---|
| **Example Usage** | working code to start from |
| **Argument Reference** | everything you can set, and which settings are required |
| **Attributes Reference** | what you can read from it after it's created, like `.id` or `.primary_web_endpoint` |
| **Import** | the ID format for `import` (exercise 11) |

The resources you use here: [resource group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) · [storage account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) · [static website](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_static_website) · [container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) · [blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob)

The symbols in a plan:

| Symbol | Means |
|---|---|
| `+` | create |
| `~` | change in place: the resource stays, a setting changes |
| `-/+` | replace: destroy, then create a new one |
| `-` | destroy |

---

## Part 1 · Change things

### 1 · Read what you deployed · 10 min

**Do:** nothing new. Look at what's there.

**Run:**
```sh
terraform state list
terraform output
```

**Expect:** the 5 resources Terraform created, and your `website_url`. Now look in the [Azure portal](https://portal.azure.com): search for your resource group `rg-tf-<your name>-…`. The same resources are there.

**Why:** the state file (`terraform.tfstate`) is Terraform's memory. It links each block in your code to a real thing in Azure. Every `plan` compares 3 things: your code, the state, and what's really in Azure.

### 2 · A change in place · 5 min

**Do:** in `main.tf`, add a second tag to the storage account:
```hcl
  tags = {
    owner  = var.your_name
    course = "terraform"
  }
```

**Run:**
```sh
terraform fmt        # lines up the = signs for you
terraform plan
```

**Expect:** `~ update in-place` on the storage account, and `Plan: 0 to add, 1 to change, 0 to destroy`. Then `terraform apply`.

**Why:** most changes are small edits to a resource that keeps existing. Nothing is lost.

### 3 · A change that replaces · 10 min

**Do (a):** in `terraform.tfvars`, add a line:
```hcl
colour = "orange"
```

**Run:** `terraform plan`

**Expect:** the `index.html` blob shows `-/+ must be replaced`, and `Plan: 1 to add, 0 to change, 1 to destroy`. Apply it, then refresh your page: it's orange.

**Do (b):** in `main.tf`, find the `name` line of the storage account and change `st` at the start to `site`:
```hcl
  name = "st${var.your_name}${random_string.suffix.result}"     # before
  name = "site${var.your_name}${random_string.suffix.result}"   # after
```

**Run:** `terraform plan`. **Don't apply.**

**Expect:** the storage account shows `-/+ must be replaced`, and the static website and `index.html` go with it. Your `website_url` would change.

**Why:** some settings can't be changed on an existing resource, like a storage account's name. Terraform deletes the old one and builds a new one. For your page that's harmless. **On a data lake, it deletes all your data.** That's why you always read the plan before you type `yes`.

Now change `site` back to `st`, and run `terraform plan` again. Expect: `No changes`. Your code matches Azure again, and nothing was deleted, because you never applied.

### 4 · Drift: someone changes it by hand · 10 min

**Do:** in the portal, open your storage account → **Tags**. Change `owner` to `someone`. **Save.**

**Run:** `terraform plan`

**Expect:** `~ tags`, with `"owner" = "someone" -> "<your name>"`. Terraform noticed that Azure no longer matches your code.

**Run:** `terraform apply`. Refresh the tags in the portal: `owner` is your name again.

**Why:** your code is the truth. Changes by hand get undone on the next `apply`. If a change by hand was right, put it in the code.

**Bonus (3 min):** in the portal, open the storage account → **Storage browser** → **Blob containers** → `$web`, and delete `index.html`. Your page is gone. Run `terraform plan`, then `terraform apply`. It's back.

---

## Part 2 · Write your own code

Until now you changed code that was already there. Now you write it. Type the code yourself instead of copying it: that's how it sticks. Keep the [provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) open next to it: try to find each setting you type on the resource's page.

### 5 · A mini data lake · 10 min

Your storage account can hold more than a website. You add a `raw` container (a folder for incoming data) and upload `data/sales.csv` into it.

**Do:** add this at the bottom of `main.tf`:
```hcl
resource "azurerm_storage_container" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.site.id
}

resource "azurerm_storage_blob" "sales" {
  name                 = "sales.csv"
  storage_container_id = azurerm_storage_container.raw.id
  type                 = "Block"
  source               = "data/sales.csv" # a file on your laptop
}
```

**Run:** `terraform plan`, then `terraform apply`.

**Expect:** `Plan: 2 to add, 0 to change, 0 to destroy`. Terraform creates the container first, then the file. In the portal: storage account → **Storage browser** → **Blob containers** → `raw` → `sales.csv`.

**Why:** `azurerm_storage_container.raw.id` is a **reference**: the file needs the container's ID. That's how Terraform knows the order. You never tell it "first this, then that".

### 6 · More files with `for_each`, without losing one · 15 min

You want to upload `customers.csv` too. Instead of copying the block, you make one block that handles a list of files.

**Do (a):** replace the whole `azurerm_storage_blob "sales"` block with:
```hcl
resource "azurerm_storage_blob" "data" {
  for_each = toset(["sales.csv", "customers.csv"])

  name                 = each.key
  storage_container_id = azurerm_storage_container.raw.id
  type                 = "Block"
  source               = "data/${each.key}"
}
```

**Run:** `terraform plan`. **Don't apply.**

**Expect:** 3 lines:
- `azurerm_storage_blob.sales` **will be destroyed**
- `azurerm_storage_blob.data["sales.csv"]` will be created
- `azurerm_storage_blob.data["customers.csv"]` will be created

`Plan: 2 to add, 0 to change, 1 to destroy`. Terraform thinks `sales.csv` is a new thing, because its name in the code changed from `sales` to `data["sales.csv"]`. It would delete your file and upload it again. On real data, that's a gap at best, and lost data at worst.

**Do (b):** tell Terraform it's the same file. Add this below the block:
```hcl
moved {
  from = azurerm_storage_blob.sales
  to   = azurerm_storage_blob.data["sales.csv"]
}
```

**Run:** `terraform plan`

**Expect:** `azurerm_storage_blob.sales has moved to azurerm_storage_blob.data["sales.csv"]`, and `Plan: 1 to add, 0 to change, 0 to destroy`. Only `customers.csv` is new. Now `terraform apply`.

**Why:** `for_each` makes one block handle many things: each item in the list becomes its own resource. `moved` changes a resource's name in the state, without touching Azure. Use it every time you rename or restructure code.

After the apply, delete the `moved` block. It has done its job. (In a team, you keep it until everyone has applied.)

**Bonus (3 min):** add `"products.csv"` to the list, create the file `data/products.csv` with any text in it, and run `terraform apply`. One more file, no new block.

### 7 · Protect your data · 5 min

**Do:** add a `lifecycle` block inside the `raw` container:
```hcl
resource "azurerm_storage_container" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.site.id

  lifecycle {
    prevent_destroy = true
  }
}
```

Run `terraform apply` once: expect `No changes`. `prevent_destroy` lives in your code, not in Azure.

**Run:** `terraform destroy`

**Expect:** `Error: Instance cannot be destroyed`. Nothing was deleted, not even your website: Terraform refuses the whole run.

**Why:** a guardrail for the things you can't get back, like data. Exercise 3 showed that a small code change can replace a resource. `prevent_destroy` blocks that too. Try it: change `"raw"` to `"bronze"` and run `plan`. Then change it back.

---

## Part 3 · Work with state

### 8 · The lock · 5 min

Two runs at the same time would both write to the same state file and damage it. Terraform locks the state while it works.

**Do:** open a **second terminal** in the same folder.

**Run:** in terminal 1:
```sh
terraform apply
```
Leave it waiting at `Enter a value:`. **Don't answer.**

In terminal 2:
```sh
terraform plan
```

**Expect:** `Error acquiring the state lock`, with **who** holds the lock and **since when**.

**Run:** in terminal 2: `terraform plan -lock-timeout=60s`. It waits. In terminal 1, answer `no`. Terminal 2 continues right away.

**Why:** the lock keeps 2 runs from writing at the same time. In a team, the state lives in shared storage and the lock works across laptops: the same thing as here, between colleagues. `terraform force-unlock` exists, but only use it when you're sure the other run is dead.

Close terminal 2.

### 9 · Lost state · 5 min

**Do:** rename the state file, as if you lost it:
```sh
mv terraform.tfstate backup.tfstate          # Windows: ren terraform.tfstate backup.tfstate
```

**Run:** `terraform plan`. **Don't apply.**

**Expect:** everything **to add**. Terraform has forgotten all of it, even though it all still exists in Azure. Applying would build a second website next to the first, with new random names, and the first would be left behind with nobody managing it.

**Do:** put it back:
```sh
mv backup.tfstate terraform.tfstate          # Windows: ren backup.tfstate terraform.tfstate
terraform plan                               # expect: No changes
```

**Why:** state is as important as your code. That's why teams keep it in shared, versioned storage, never on one laptop. (`terraform.tfstate.backup` is Terraform's own copy of your previous state.)

### 10 · Hand files to another team: `removed` · 10 min

Another team takes over your CSV files. They must keep existing, but you stop managing them.

**Do (a):** the obvious move: you don't manage the files anymore, so you take them out of your code. Comment out the whole `azurerm_storage_blob "data"` block by putting `#` in front of every line:
```hcl
# resource "azurerm_storage_blob" "data" {
#   for_each = toset(["sales.csv", "customers.csv"])
#
#   name                 = each.key
#   storage_container_id = azurerm_storage_container.raw.id
#   type                 = "Block"
#   source               = "data/${each.key}"
# }
```

**Run:** `terraform plan`. **Don't apply.**

**Expect:** `- destroy` on both files, `Plan: 0 to add, 0 to change, 2 to destroy`.

That's not what you meant. You wanted to *stop managing* the files, but Terraform reads it differently: "it's in my state, it's no longer in the code, so it should no longer exist". **Commenting out or deleting code means deleting the resource.** Apply this, and the other team loses its files.

**Do (b):** tell Terraform to let go instead. Leave the block commented out, and add:
```hcl
removed {
  from = azurerm_storage_blob.data

  lifecycle {
    destroy = false
  }
}
```

**Run:** `terraform plan`

**Expect:** both files `will no longer be managed by Terraform`, and `0 to destroy`. Now `terraform apply`.

**Check:** `terraform state list` no longer shows the files. The portal still does.

**Why:** `removed` takes something out of your state without deleting it in Azure. The other team can now take it over with `import` (next exercise). The older way is `terraform state rm`: it does the same, but without a plan to review first.

After the apply, delete the `removed` block and the commented-out `data` block: they've done their job. (In a team, keep `removed` until every state that uses this code has applied it. A state that hasn't would see the block gone and plan a destroy.)

### 11 · Take over something made by hand: `import` · 15 min

Someone made a container by hand in the portal. Your team will manage it from now on.

**Do (a):** in the portal: storage account → **Storage browser** → **Blob containers** → **Add container**. Name it `archive`, then **Create**.

**Do (b):** add this to `main.tf`. It says: "put the existing container into my state, at the address `azurerm_storage_container.archive`".
```hcl
import {
  to = azurerm_storage_container.archive
  id = "${azurerm_storage_account.site.id}/blobServices/default/containers/archive"
}
```

**Run:** `terraform plan`

**Expect:** `Error: Configuration for import target does not exist`. Terraform knows *where* to put the container in state, but there's no code for it yet. Every resource in state needs a block in your code.

**Do (c):** write that block yourself. It looks like your `raw` container from exercise 5:
```hcl
resource "azurerm_storage_container" "archive" {
  name               = "archive"
  storage_account_id = azurerm_storage_account.site.id
}
```

**Run:** `terraform plan`

**Expect:** `Plan: 1 to import, 0 to add, 0 to change, 0 to destroy`. Your code matches the real container exactly, so nothing changes. If you see `~`, your block differs from what's in Azure: Terraform would change the real container to match your code. Fix the block until it says `0 to change`.

**Do (d): the shortcut.** Writing blocks by hand is fine for 1 container, but slow for 50 resources. Terraform can write them for you. Comment out your `archive` block with `#`, then:

```sh
terraform plan -generate-config-out=generated.tf
```

**Expect:** the same `Plan: 1 to import, 0 to add, 0 to change, 0 to destroy`, and a new file `generated.tf`. Open it: Terraform read the real container in Azure and wrote the block for you. Compare it with yours. The generated one has the full storage account ID typed out where you used `azurerm_storage_account.site.id`, and it may list settings you left out. Generated code works, but you tidy it up before you keep it.

**Do (e):** keep your own version. Delete `generated.tf`, and remove the `#` from your `archive` block. Two blocks for the same address is an error.

**Run:** `terraform apply`. Expect: `Resources: 1 imported, 0 added, 0 changed, 0 destroyed`. Then run `terraform state list`: `archive` is there.

**Why:** `import` brings an existing resource into your state without changing it. It's how teams move hand-made resources into code. After the apply, delete the `import` block: it has done its job.

**Bonus with a neighbour (10 min):** two states, one resource. Import your neighbour's `archive` container into **your** state too: use their storage account's ID in the `id`, and give it a new name, like `azurerm_storage_container.neighbour`. Now you both manage it. Your neighbour adds `metadata = { owner = "<their name>" }` to it and applies. Run `plan`: Terraform wants to undo their change. You'd keep undoing each other's changes. **One resource, one owner.** Fix it the way you learned in exercise 10: you add a `removed` block for `neighbour`.

---

## The end

### 12 · Remove everything · 5 min

**Do:** if you did exercise 7, delete the `lifecycle { prevent_destroy = true }` block first. Otherwise `destroy` refuses, as you saw.

**Run:**
```sh
terraform destroy    # read the list, then answer: yes
```

**Expect:** your page stops working. Your resource group is gone from the portal. It takes 1–3 minutes.

**Why:** everything Terraform created, Terraform can remove, and only that. Your neighbour's page still works: your state file only knows about your resources.

One catch: the CSV files you handed over in exercise 10 are gone too. They lived inside your storage account, and the account was deleted. In real life you'd hand over the storage account with them, or move the data first. Handing something over means checking what it lives in.

**Done.**

---

## When something goes wrong

| You see | Why | Do |
|---|---|---|
| `Invalid value for variable` on `your_name` | Your name has capitals, spaces, digits or a dash | Use only lowercase letters in `terraform.tfvars` |
| `404 WebsiteDisabled` in the browser | Azure is still switching the website on | Wait 2 minutes, refresh |
| `403` or `AuthorizationFailed` | Your account has no access to the training subscription yet | Tell your trainer |
| `subscription … could not be found` | You're logged in with another account | `az logout`, then `az login` with the right account |
| `terraform: command not found` | The terminal started before the install | Open a new terminal |
| The portal's Storage browser says key-based authentication is not permitted | Storage keys are off on purpose | Click **Switch to Microsoft Entra user account** |
| `Instance cannot be destroyed` on `destroy` | `prevent_destroy` from exercise 7 | Delete the `lifecycle` block, then `destroy` again |
