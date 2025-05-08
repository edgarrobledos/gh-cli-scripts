#!/bin/bash
set -e

# === Default values ===
TARGET_BRANCH="features/qa/current"
HEAD_BRANCH="develop"
REPO_PATH=""

# === Parse flags ===
while [[ $# -gt 0 ]]; do
    case "$1" in
    --path)
        REPO_PATH="$2"
        shift 2
        ;;
    --target-branch)
        TARGET_BRANCH="$2"
        shift 2
        ;;
    --head-branch)
        HEAD_BRANCH="$2"
        shift 2
        ;;
    --auto-merge)
        AUTO_MERGE=true
        shift 1
        ;;
    --body)
        CUSTOM_BODY="$2"
        shift 2
        ;;
    --title)
        CUSTOM_TITLE="$2"
        shift 2
        ;;
    *)
        echo "❌ Unknown option: $1"
        echo "Usage: $0 [--path <repo-path>] [--target-branch <branch>] [--head-branch <branch>] [--body <body>] [--title <title>]"
        exit 1
        ;;
    esac
done

# === If path was provided, cd into it ===
if [ -n "$REPO_PATH" ]; then
    if [ ! -d "$REPO_PATH/.git" ]; then
        echo "❌ The provided path is not a Git repository: $REPO_PATH"
        exit 1
    fi
    cd "$REPO_PATH"
    echo "📁 Changed directory to: $REPO_PATH"
fi

# === Main logic ===
echo "Fetching latest release info..."
RELEASE_JSON=$(gh release list --limit 1 --json tagName,name --jq '.[0]')
LATEST_TAG=$(echo "$RELEASE_JSON" | jq -r '.tagName')
RELEASE_NAME=$(echo "$RELEASE_JSON" | jq -r '.name')

if [ -z "$LATEST_TAG" ]; then
    echo "❌ No release tag found. Make sure there is at least one release."
    exit 1
fi

RELEASE_BODY=$(gh release view "$LATEST_TAG" --json body --jq '.body')

echo "✅ Latest release tag: $LATEST_TAG"

if [ -z "$CUSTOM_BODY" ]; then
    PR_BODY="$RELEASE_BODY"
else
    PR_BODY="$CUSTOM_BODY"
fi

if [ -z "$CUSTOM_TITLE" ]; then
    PR_TITLE="chore: merge $HEAD_BRANCH $LATEST_TAG"
else
    PR_TITLE="$CUSTOM_TITLE"
fi

echo "Creating pull request..."
PR_URL=$(gh pr create \
    --base "$TARGET_BRANCH" \
    --head "$HEAD_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --assignee "@me" \
    --reviewer "sang-avalonbay")

echo "📌 Pull request created: $PR_URL"

# === Auto-merge if requested ===
if [ "$AUTO_MERGE" = true ]; then
    echo "🌀 Enabling auto-merge..."
    gh pr merge "$PR_URL" --auto --merge
    echo "✅ Auto-merge enabled! GitHub will merge the PR once all checks pass."
fi