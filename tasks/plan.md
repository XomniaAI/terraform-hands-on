# Plan: Terraform hands-on for trainees

## Overview

The smallest Terraform example trainees deploy themselves, from their own laptops, during the "Terraform for data platforms" course. Each trainee deploys their own resource group with a static website in a storage account, in the course subscription `training`. They open the URL and see a page with their own name and colour. They change it, watch drift, and destroy it.

Trainees run only `init`, `plan`, `apply`, `output` and `destroy`. They never set up access, backends or CI. That is covered by the trainers' demo (`terraform-live-poll-demo`).

## What the trainee gets

```
terraform-hands-on/
├── README.md         install, az login, the 5 commands
├── main.tf           resource group, storage account, static website, index.html blob, random suffix
├── variables.tf      your_name, colour
├── outputs.tf        website_url
├── terraform.tf      Terraform + provider versions, provider settings
├── terraform.tfvars  your_name = "change-me"   ← the only file trainees edit
└── EXERCISES.md      the 5 exercises
```

Plus, for trainers only: `TRAINERS.md`, the checklist before and after a session.

## Decisions

| Decision | Why |
|---|---|
| Static website on a storage account | Visible in the browser. A storage account is the "bucket" from the course deck. Costs cents. |
| Each trainee creates their own resource group | Easier to explain than a shared group: everything you make is in your group, and `destroy` removes the whole group. No data source to explain. |
| A dedicated subscription, `training` | Trainees get Contributor on the whole subscription, so it must hold nothing else. A budget alert limits the cost risk. |
| Trainers grant 2 roles on the subscription, once | Contributor + Storage Blob Data Contributor. Trainees never touch access. |
| Random suffix on every name | Storage names are global, and 2 trainees can pick the same name. Also shows that state keeps the random value between runs. |
| Local state | No backend to set up. Remote state is shown in the demo. Each trainee's state only knows their own resources, so `destroy` can't touch anyone else's. |
| Subscription and region are fixed in the code | Trainees never type them. |
| `resource_provider_registrations = "none"` | Trainers register `Microsoft.Storage` once. Skipping registration makes `init` and `plan` faster. |
| `storage_use_azuread = true`, keys off | Writing `index.html` uses the trainee's Azure login, not storage keys. Needs the Storage Blob Data Contributor role. |
| Same versions as the demo: Terraform `~> 1.16`, azurerm `~> 5.8` | One set of install instructions for the whole course. |

## Exercises (~45 min, guided)

1. **init → plan → apply → output** (10 min): open the URL, see your page.
2. **Change in place** (5 min): add a tag. `plan` shows `~`.
3. **Change that replaces** (10 min): change `colour`, the blob shows `-/+`. Then rename the storage account: the URL changes. On a data lake, that is lost data (deck slide 32).
4. **Drift** (10 min): change the tag in the portal, run `plan`, apply to put it back.
5. **destroy** (5 min): the URL stops working and your resource group disappears from the portal. Everyone else's sites still work.

## Task list

Tasks with acceptance criteria: [todo.md](todo.md).

### Phase 1: The thing works (as Owner)
- [x] Task 1: Terraform code deploys a page you can open
- [x] Task 2: Change and drift behave as the exercises say

### Checkpoint 1
- [ ] Ji reviews the code and the page

### Phase 2: It works as a trainee
- [ ] Task 3: Test with only the 2 trainee roles
- [ ] Task 4: README for trainees

### Checkpoint 2
- [ ] A non-Owner account runs the README from start to finish

### Phase 3: Ready for a session
- [ ] Task 5: EXERCISES.md
- [ ] Task 6: TRAINERS.md
- [ ] Task 7: Dry run with Fokke

### Checkpoint 3
- [ ] Fokke completes all 5 exercises from their laptop, with only the README

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Static website setup needs a data-plane role that isn't granted | High: `apply` fails for every trainee | Task 3 tests with exactly the trainee roles, before writing docs |
| Trainees can create anything in the subscription, including expensive resources | Medium: cost | Dedicated subscription, budget alert (TRAINERS.md), cleanup after each session |
| `Microsoft.Storage` not registered in the new subscription | High: `apply` fails for everyone | Trainers register it once (TRAINERS.md) |
| Changing `source_content` updates in place instead of replacing | Low: exercise 3 tells a different story | Task 2 checks the real plan and the exercise follows it |
| Trainees on Windows, without Terraform or az installed | Medium: lost first 15 min | README has install lines for macOS and Windows. Send it a day before. |
| Role propagation | Medium: 403 at the start | Trainers grant roles the day before (TRAINERS.md) |
| Trainees from other companies have no account in the Xomnia tenant | High: no `az login` | Open question 2 |

## Open questions

1. ~~Where do trainees deploy?~~ Subscription `training` (`e01d7df5-1ecb-4abe-98d3-0357f2637147`), region `westeurope`. Ji is Owner. Each trainee creates their own resource group.
2. Do trainees have an Entra account in that tenant (Xomnia staff, or invited guests)?
3. Is there an Entra group for trainees, so the 2 roles are granted once, not per person?
