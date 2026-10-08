# Notes: real behaviour, for README and EXERCISES

## Task 1 (2026-10-08, as Ji, Owner)

- `apply` creates 5 resources: random_string, resource group, storage account, static website, blob.
- Right after `apply`, the URL gives `404 WebsiteDisabled` for 1–5 minutes. Then the page works. README must say: "wait 2 minutes, then refresh".

## Task 2 (2026-10-08)

- Adding a tag to the storage account: `~ update in-place`, `0 to add, 1 to change, 0 to destroy`.
- Changing `colour`: the blob is **replaced** (`-/+`, `1 to add, 0 to change, 1 to destroy`). In azurerm v5.8.0, `source_content` is `ForceNew` (`storage_blob_resource.go:122`). The page changes after apply. Good for exercise 3: a harmless replace, before the storage account rename.
- Drift: a tag changed in the portal shows as `~ tags` in `plan`; `apply` puts it back.
- `destroy`: 5 destroyed. The resource group takes 1–3 minutes to delete.

## Not verified yet (check in Task 7)

- Exercise 3b: renaming the storage account replaces the account, the static website and the blob (expected `3 to add, 0 to change, 3 to destroy`; not run).
- Exercise 4 bonus: deleting `index.html` in the portal shows `+ create` for the blob (not run).
- Exercise 3a: does the browser cache the old colour? A hard refresh may be needed.
