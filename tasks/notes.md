# Notes: real behaviour, for README and EXERCISES

## Task 1 (2026-10-08, as Ji, Owner)

- `apply` creates 5 resources: random_string, resource group, storage account, static website, blob.
- Right after `apply`, the URL gives `404 WebsiteDisabled` for 1–5 minutes. Then the page works. README must say: "wait 2 minutes, then refresh".

## Task 2 (2026-10-08)

- Adding a tag to the storage account: `~ update in-place`, `0 to add, 1 to change, 0 to destroy`.
- Changing `colour`: the blob is **replaced** (`-/+`, `1 to add, 0 to change, 1 to destroy`). In azurerm v5.8.0, `source_content` is `ForceNew` (`storage_blob_resource.go:122`). The page changes after apply. Good for exercise 3: a harmless replace, before the storage account rename.
- Drift: a tag changed in the portal shows as `~ tags` in `plan`; `apply` puts it back.
- `destroy`: 5 destroyed. The resource group takes 1–3 minutes to delete.
