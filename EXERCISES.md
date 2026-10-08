# Exercises

**~45 min · 5 exercises · do them in order.** Start when your page is live ([README.md](README.md), step 5).

Each exercise has the same shape: **do** something, **run** a command, **expect** what you'll see, and **why** it matters.

The symbols in a plan:

| Symbol | Means |
|---|---|
| `+` | create |
| `~` | change in place: the resource stays, a setting changes |
| `-/+` | replace: destroy, then create a new one |
| `-` | destroy |

---

## 1 · Read what you deployed · 10 min

**Do:** nothing new. Look at what's there.

**Run:**
```sh
terraform state list
terraform output
```

**Expect:** the 5 resources Terraform created, and your `website_url`. Now look in the [Azure portal](https://portal.azure.com): search for your resource group `rg-tf-<your name>-…`. The same resources are there.

**Why:** the state file (`terraform.tfstate`) is Terraform's memory. It links each block in your code to a real thing in Azure. Every `plan` compares 3 things: your code, the state, and what's really in Azure.

---

## 2 · A change in place · 5 min

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

---

## 3 · A change that replaces · 10 min

**Do (a):** in `terraform.tfvars`, add a line:
```hcl
colour = "orange"
```

**Run:** `terraform plan`

**Expect:** the `index.html` blob shows `-/+ must be replaced`, and `Plan: 1 to add, 0 to change, 1 to destroy`. Apply it, then refresh your page: it's orange.

**Do (b):** in `main.tf`, change the storage account name from `"st${…` to `"site${…`.

**Run:** `terraform plan`. **Don't apply.**

**Expect:** the storage account shows `-/+ must be replaced`, and the static website and `index.html` go with it. Your `website_url` would change.

**Why:** some settings can't be changed on an existing resource, like a storage account's name. Terraform deletes the old one and builds a new one. For your page that's harmless. **On a data lake, it deletes all your data.** That's why you always read the plan before you type `yes`.

Now change the name back to `"st${…`, and run `terraform plan` again. Expect: `No changes`. Nothing happened, because you didn't apply.

---

## 4 · Drift: someone changes it by hand · 10 min

**Do:** in the portal, open your storage account → **Tags**. Change `owner` to `someone`. **Save.**

**Run:** `terraform plan`

**Expect:** `~ tags`, with `"owner" = "someone" -> "<your name>"`. Terraform noticed that Azure no longer matches your code.

**Run:** `terraform apply`. Refresh the tags in the portal: `owner` is your name again.

**Why:** your code is the truth. Changes by hand get undone on the next `apply`. If a change by hand was right, put it in the code.

**Bonus (3 min):** in the portal, open the storage account → **Containers** → `$web`, and delete `index.html`. Your page is gone. Run `terraform plan`, then `terraform apply`. It's back.

---

## 5 · Remove everything · 5 min

**Run:**
```sh
terraform destroy    # expect: 5 to destroy, answer: yes
```

**Expect:** your page stops working. Your resource group is gone from the portal. It takes 1–3 minutes.

**Why:** everything Terraform created, Terraform can remove, and only that. Your neighbour's page still works: your state file only knows about your resources.

**Done.**
