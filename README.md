# Terraform hands-on: your own website on Azure

You deploy a small web page to Azure with Terraform, from your own laptop. It shows your name, in your colour. Then you change it, break it, and remove it again.

**~15 min to get your page live. Then the exercises: [EXERCISES.md](EXERCISES.md).**

What Terraform creates for you:

| Resource | What it is |
|---|---|
| A resource group, `rg-tf-<your name>-<6 random characters>` | a folder in Azure that holds everything below |
| A storage account | Azure's file storage: the "bucket" from the course |
| Static website hosting | lets the storage account serve web pages |
| `index.html` | your page |
| 6 random characters | so your names never clash with another trainee's |

---

## 1 · Install · 5–10 min

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

## 2 · Log in to Azure · 2 min

```sh
az login
```

A browser opens. Log in with the account your trainer gave access to. If it asks you to pick a subscription, pick **training**.

## 3 · Get the code · 1 min

```sh
git clone <repo-url> terraform-hands-on
cd terraform-hands-on
```

## 4 · Put in your name · 1 min

Open `terraform.tfvars` and change `change-me` to your name: 2 to 12 lowercase letters, no spaces.

```hcl
your_name = "anna"
```

## 5 · Deploy · 5 min

```sh
terraform init       # downloads the Azure plugin. Once per folder.
terraform plan       # shows what Terraform WOULD do. Read it: expect 5 to add.
terraform apply      # does it. Shows the plan again, then answer: yes
terraform output     # prints your website_url
```

Open the `website_url` in your browser.

**The first 1–2 minutes you may see `404 WebsiteDisabled`.** Azure is still switching your website on. Wait 2 minutes, then refresh.

Now do the exercises: [EXERCISES.md](EXERCISES.md).

## 6 · Remove everything · 3 min

At the end of the session:

```sh
terraform destroy    # expect: 5 to destroy, answer: yes
```

Your page stops working and your resource group disappears from Azure. Other trainees' pages keep working: your Terraform only knows about your own resources.

---

## When something goes wrong

| You see | Why | Do |
|---|---|---|
| `Invalid value for variable` on `your_name` | Your name has capitals, spaces, digits or a dash | Use only lowercase letters in `terraform.tfvars` |
| `404 WebsiteDisabled` in the browser | Azure is still switching the website on | Wait 2 minutes, refresh |
| `403` or `AuthorizationFailed` | Your account has no access to the training subscription yet | Tell your trainer |
| `subscription … could not be found` | You're logged in with another account | `az logout`, then `az login` with the right account |
| `terraform: command not found` | The terminal started before the install | Open a new terminal |
