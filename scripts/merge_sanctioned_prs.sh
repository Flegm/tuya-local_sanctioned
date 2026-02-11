#!/usr/bin/env bash
# Merge all PRs with "sanctioned" label from make-all/tuya-local into current branch.
# Use: run from a clone of make-all/tuya-local, then push to Flegm/tuya-local_sanctioned.
#
# Prerequisites:
#   git clone https://github.com/make-all/tuya-local.git
#   cd tuya-local
#   git remote add myfork https://github.com/Flegm/tuya-local_sanctioned.git
#
# Find open sanctioned PRs: https://github.com/make-all/tuya-local/pulls?q=is:pr+is:open+label:sanctioned
#
# Then run: ./scripts/merge_sanctioned_prs.sh

set -e

# List of PR numbers with "sanctioned" label (update from the link above when new ones appear)
# Current open PRs: 2988, 3305, 3555, 3756, 3881, 3964, 4137, 4271
SANCTIONED_PRS=(2988 3305 3555 3756 3881 3964 4137 4271)

# Use upstream (make-all/tuya-local) to fetch PRs; origin may be your fork
REMOTE=upstream
if ! git remote get-url "$REMOTE" &>/dev/null; then
  REMOTE=origin
fi
echo "Fetching from $REMOTE (make-all/tuya-local)..."
git fetch "$REMOTE"

for pr in "${SANCTIONED_PRS[@]}"; do
  echo "--- Merging PR #$pr ---"
  git fetch "$REMOTE" "pull/$pr/head:pr-$pr" 2>/dev/null || true
  if git show-ref -q "refs/heads/pr-$pr"; then
    git merge "pr-$pr" -m "Merge sanctioned PR #$pr from make-all/tuya-local"
    git branch -d "pr-$pr" 2>/dev/null || true
  else
    echo "  Could not fetch PR #$pr, skipping."
  fi
done

echo "Done. Push to fork: git push myfork main"
