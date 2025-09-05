#!/usr/bin/env bash
set -euo pipefail

# Push this project to your GitHub repository.
#
# Usage examples:
#   ./scripts/push_to_github.sh --repo https://github.com/USER/REPO.git
#   ./scripts/push_to_github.sh --repo https://github.com/USER/REPO.git --fresh
#   GITHUB_USER=USER GITHUB_TOKEN=XXXXXXXX \
#     ./scripts/push_to_github.sh --repo https://github.com/USER/REPO.git
#
# Notes
# - If --fresh is NOT provided, we keep full git history and just update the remote.
# - If --fresh is provided, we re‑initialize git and push a single clean commit.
# - If GITHUB_TOKEN and GITHUB_USER are provided, we prefill credentials for HTTPS pushes
#   using git-credential; otherwise git will prompt.

REPO_URL=""
FRESH=0
USER_NAME=""
USER_EMAIL=""
COMMIT_MSG="Initial commit: import project"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_URL=${2:-}; shift 2 ;;
    --fresh)
      FRESH=1; shift ;;
    --user-name)
      USER_NAME=${2:-}; shift 2 ;;
    --user-email)
      USER_EMAIL=${2:-}; shift 2 ;;
    --commit-msg)
      COMMIT_MSG=${2:-}; shift 2 ;;
    *)
      echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$REPO_URL" ]]; then
  echo "--repo is required (e.g., --repo https://github.com/zorluhan/bu.git)" >&2
  exit 2
fi

# Optional: configure identity for this repo
if [[ -n "$USER_NAME" ]]; then git config user.name "$USER_NAME"; fi
if [[ -n "$USER_EMAIL" ]]; then git config user.email "$USER_EMAIL"; fi

# If provided, pre-authorize the HTTPS credential (safe on macOS: stored in Keychain)
if [[ -n "${GITHUB_TOKEN:-}" && -n "${GITHUB_USER:-}" ]]; then
  if command -v git >/dev/null 2>&1; then
    printf "protocol=https\nhost=github.com\nusername=%s\npassword=%s\n\n" "$GITHUB_USER" "$GITHUB_TOKEN" | git credential approve >/dev/null 2>&1 || true
  fi
fi

# Detect if this is a git repo already
if [[ $FRESH -eq 1 ]]; then
  echo "[push] Fresh start: re-initializing repository"
  rm -rf .git
  git init
  git add -A
  git commit -m "$COMMIT_MSG"
  git branch -M main
  git remote add origin "$REPO_URL" || git remote set-url origin "$REPO_URL"
  git push -u origin main
  git push -u origin --tags || true
  echo "[push] Done. Repo pushed (fresh) → $REPO_URL"
  exit 0
fi

echo "[push] Keeping history: wiring remote and pushing all branches/tags"
if [[ -d .git ]]; then
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REPO_URL"
  else
    git remote add origin "$REPO_URL"
  fi
else
  echo "No .git directory found. Use --fresh to initialize a new repo." >&2
  exit 2
fi

# Ensure current work is committed (optional, skip if nothing to commit)
if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  git commit -m "chore: save working tree before push"
fi

# Push all branches and tags
git push -u origin --all
git push -u origin --tags || true
echo "[push] Done. Repo pushed → $REPO_URL"

