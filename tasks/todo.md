# Todo: Terraform hands-on

Plan and decisions: [plan.md](plan.md).

## Phase 1: The thing works (as Owner)

### Task 1: Terraform code deploys a page you can open · S · ~45 min

**Description:** Write the Terraform for one trainee: random suffix, resource group, storage account, static website, `index.html` blob with the trainee's name and colour. Test it as Ji (Owner) in the `training` subscription.

**Acceptance criteria:**
- [x] `terraform apply` creates 5 resources, with no other input than `your_name` in `terraform.tfvars`
- [x] `terraform output website_url` prints a URL, and the browser shows "Hello from <name>" in the chosen colour (not a file download)
- [x] `terraform destroy` removes all 5, the URL stops working, and the resource group is gone

**Verification:**
- [x] `terraform fmt -check` and `terraform validate` pass
- [x] Manual: open the URL before and after destroy

**Dependencies:** Ji has Storage Blob Data Contributor on the subscription, and `Microsoft.Storage` is registered

**Files:** `terraform.tf`, `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`, `.gitignore`

### Task 2: Change and drift behave as the exercises say · XS · ~20 min

**Description:** Run exercises 2–4 against the Task 1 deployment and write down the real plan output. Adjust the exercises if Terraform behaves differently.

**Acceptance criteria:**
- [x] Adding a tag: plan shows `~ update in-place`
- [x] Changing `colour`: plan shows what happens to the blob (`-/+` or `~`), and the page changes after apply
- [x] Changing a tag in the portal: `plan` shows the drift, `apply` puts it back

**Verification:**
- [x] Plan outputs pasted into `tasks/notes.md`, for writing EXERCISES.md

**Dependencies:** Task 1

**Files:** `tasks/notes.md`

### Checkpoint 1
- [ ] Ji reviews the code and the page

## Phase 2: It works as a trainee

### ~~Task 3: Test with only the 2 trainee roles~~ · dropped: trainers test it themselves

**Description:** Log in as an account that has only Contributor and Storage Blob Data Contributor on the `training` subscription, and run the full cycle.

**Acceptance criteria:**
- [ ] `init`, `plan`, `apply`, `output`, `destroy` all work with only those 2 roles
- [ ] No errors about resource provider registration or storage keys
- [ ] 2 deployments side by side (2 different `your_name`) don't collide

**Verification:**
- [ ] Manual: both URLs open at the same time, then destroy one and the other still works

**Dependencies:** Task 1, open questions 2–3

**Files:** `terraform.tf`, `main.tf`

### Task 4: README for trainees · S · ~30 min

**Description:** Install Terraform and az (macOS + Windows), `az login`, set `your_name`, the 5 commands. Plain English, in the same style as the demo's README.

**Acceptance criteria:**
- [ ] A trainee who has never used Terraform gets to a working URL with only the README
- [ ] Install takes under 10 min on a fresh laptop
- [ ] No step mentions roles, backends or subscriptions beyond `az login`

**Verification:**
- [ ] Manual: follow it word for word on a laptop that hasn't run this before

**Dependencies:** Task 3

**Files:** `README.md`

### Checkpoint 2
- [ ] A non-Owner account runs the README from start to finish

## Phase 3: Ready for a session

### Task 5: EXERCISES.md · S · ~45 min

**Description:** The 5 exercises from plan.md, each with: what to change, the command, what to expect (from `tasks/notes.md`), and the one-line lesson.

**Acceptance criteria:**
- [ ] Each exercise fits in its time slot (45 min total)
- [ ] Every "expect" line matches real Terraform output
- [ ] Ends with `destroy`, so nothing is left running

**Verification:**
- [ ] Manual: run all 5 in order, timing each

**Dependencies:** Task 2, Task 4

**Files:** `EXERCISES.md`

### Task 6: TRAINERS.md · XS · ~20 min

**Description:** The trainers' checklist: register `Microsoft.Storage` once, set a budget alert once, grant the 2 roles on the subscription the day before, delete leftover `rg-tf-*` groups after, expected cost.

**Acceptance criteria:**
- [ ] Contains the exact `az role assignment create` commands
- [ ] Contains one command that lists and deletes leftover `rg-tf-*` groups after a session

**Verification:**
- [ ] Manual: run the cleanup command with 2 leftover deployments

**Dependencies:** Task 3

**Files:** `TRAINERS.md`

### ~~Task 7: Dry run with Fokke~~ · dropped: trainers test it themselves

**Description:** Fokke runs README + EXERCISES from their own laptop, as a trainee, without help. Note every question they ask.

**Acceptance criteria:**
- [ ] All 5 exercises done in under 60 min, install included
- [ ] Every question Fokke asked is answered in the docs afterwards

**Verification:**
- [ ] Manual: no `rg-tf-*` group is left after their `destroy`

**Dependencies:** Tasks 4–6

**Files:** `README.md`, `EXERCISES.md` (fixes)

### Checkpoint 3
- [ ] Fokke completes all 5 exercises from their laptop, with only the README
