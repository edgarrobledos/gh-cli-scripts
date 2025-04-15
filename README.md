# 🚀 Auto PR Creator Script

This bash script automates the creation of a Pull Request (PR) using the GitHub CLI, based on the latest release tag. It optionally supports auto-merging once all checks pass.

---

## ✅ Features

- Fetches the latest release tag and description.
- Creates a PR from one branch to another.
- Supports working inside a specific path/repo.
- Optionally enables GitHub auto-merge for the PR.

---

## 🧩 Requirements

- [GitHub CLI (`gh`)](https://cli.github.com/)
- [jq](https://stedolan.github.io/jq/)
- Access to a GitHub repository with at least one release.

---

## 📦 Usage

```bash
./create-pr.sh [--path <repo-path>] [--target-branch <branch>] [--head-branch <branch>] [--auto-merge]
```

## Additional Flag Details

🔹 --path:
Useful when you're running the script from outside the repo.
Must point to a valid Git repository (.git folder must exist).

🔹 --target-branch:
The branch into which changes will be merged (typically your dev branch).
This should exist on the remote repo and meet any branch protection rules.

🔹 --head-branch:
The branch containing the latest changes (typically main or a release branch).
The script uses this as the source of the PR.

🔹 --auto-merge:
Automatically merges the PR when all conditions are met (CI, reviews, etc.).
Requires auto-merge to be enabled in the repository settings.
Merge strategy used is --merge (create a merge commit).

## Examples

1. Basic usage from current directory

   ```shell
   ./create-pr.sh
   ```
   
   Creates a PR from main to develop using the latest release description.

2. From a specific repo path
   ```shell
   ./create-pr.sh --path ./my-repo
   ```
3. With custom branches
    ```shell
    ./create-pr.sh --target-branch staging --head-branch release
    ```
4. With auto-merge enabled
    ```shell
    ./create-pr.sh --auto-merge
    ```
5. Full example
    ```shell
    ./create-pr.sh --path ./my-repo --target-branch develop --head-branch main --auto-merge
    ```
