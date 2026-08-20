# Push this public ATG pack to GitHub

Git root: `C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\github-atg-lab`

The first commit on **main** is done locally. **Do not push until you intend to publish.**

Do **not** git-init or push the parent folder `LTE_5g_ATG_emulation_lab` (runtime caches, 3GPP PDFs, private scripts).

Replace `<your-username>` with your GitHub account. Suggested name: `LTE-5G-Air-to-Ground-ATG-Emulation-Lab`.

## 1. Create an empty public GitHub repo

**New repository** → public → **no** README / license / gitignore (this pack already has them).

Or:

```powershell
cd C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\github-atg-lab
gh repo create LTE-5G-Air-to-Ground-ATG-Emulation-Lab --public --source=. --remote=origin --push
```

`--push` publishes immediately. Omit `--push` to review first.

## 2. Add remote and push `main` (no force)

```powershell
cd C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\github-atg-lab
git remote add origin https://github.com/<your-username>/LTE-5G-Air-to-Ground-ATG-Emulation-Lab.git
git branch -M main
git push -u origin main
```

SSH:

```powershell
git remote add origin git@github.com:<your-username>/LTE-5G-Air-to-Ground-ATG-Emulation-Lab.git
git branch -M main
git push -u origin main
```

## 3. Private scripts (optional, separate)

`github-atg-lab-private` is a **different** repo. If you publish it, use **private** visibility. See that folder’s `PUSH.md`.

## Do not

- `git push --force` to `main`
- Commit `.env`, keys, `*.pcap`, `*.pdf`, or `atg-observability/data/`
- Push the full parent lab tree
