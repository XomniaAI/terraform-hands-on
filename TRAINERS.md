# For trainers

Trainees deploy into the `training` subscription. Each trainee gets their own resource group, `rg-tf-<name>-<random>`. They never touch access: you set it up here.

```sh
SUB=e01d7df5-1ecb-4abe-98d3-0357f2637147
az account set --subscription $SUB
```

---

## Once per subscription · 10 min

1. Register storage, so `apply` doesn't fail on a new subscription:
   ```sh
   az provider register -n Microsoft.Storage
   az provider show -n Microsoft.Storage --query registrationState -o tsv   # expect: Registered
   ```
2. Set a budget alert. Trainees can create anything in this subscription, so you want to know if someone starts something expensive. Portal → **Cost Management** → **Budgets** → **Add**: monthly, **€20**, alert at 80% to both trainers' email.

## The day before a session · 10 min

Roles take up to 30 minutes to work, so don't do this on the morning itself.

1. Make sure every trainee has an account in this tenant. Colleagues already do. External trainees need a guest invite: Portal → **Microsoft Entra ID** → **Users** → **Invite external user**.
2. Put the trainees in one Entra group, so you grant roles once, not per person: Portal → **Microsoft Entra ID** → **Groups** → **New group** (Security), for example `tf-training-trainees`.
3. Give the group the 2 roles on the subscription:
   ```sh
   GROUP=$(az ad group show -g tf-training-trainees --query id -o tsv)
   for role in "Contributor" "Storage Blob Data Contributor"; do
     az role assignment create --assignee-object-id $GROUP --assignee-principal-type Group \
       --role "$role" --scope /subscriptions/$SUB
   done
   ```
   | Role | Why |
   |---|---|
   | Contributor | create and delete resource groups and storage accounts |
   | Storage Blob Data Contributor | upload `index.html`. Contributor alone can't write files inside storage. |
4. Run the README yourself, start to finish, with your own name (10 min). Then `terraform destroy`.

## After a session · 5 min

Trainees should run `terraform destroy`. Some forget. List what's left:

```sh
az group list --query "[?starts_with(name, 'rg-tf-')].name" -o tsv
```

Delete all of it:

```sh
for rg in $(az group list --query "[?starts_with(name, 'rg-tf-')].name" -o tsv); do
  az group delete -n $rg --yes --no-wait
done
```

After the last session of a course, take the roles away again:

```sh
for role in "Contributor" "Storage Blob Data Contributor"; do
  az role assignment delete --assignee $GROUP --role "$role" --scope /subscriptions/$SUB
done
```

## Cost

About **€0**. A storage account has no fixed price: you pay for what's stored and downloaded. One small page per trainee is a fraction of a cent per month. The only real cost risk is a trainee creating something else, which is what the budget alert is for.

## Troubleshooting

| Trainee sees | Cause | Fix |
|---|---|---|
| `AuthorizationFailed` on the resource group | Not in the group yet, or the role hasn't propagated | Check group membership. Roles can take up to 30 min. |
| `403` while uploading `index.html` | Missing Storage Blob Data Contributor | Step 3 of "The day before" |
| `MissingSubscriptionRegistration` | `Microsoft.Storage` isn't registered | "Once per subscription", step 1 |
| `subscription … could not be found` | Logged in with another account or tenant | `az login` with the account in the trainee group |
