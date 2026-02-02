# Dotfiles Repository

## SECRETS WARNING

**Before ANY commit, verify no secrets are being committed.**

### Patterns to Watch For
- API keys, auth tokens, passwords
- Private SSH/GPG keys (public keys are fine)
- AWS/cloud credentials
- Database connection strings with passwords
- OAuth tokens or client secrets
- Files named: `.env`, `credentials`, `secrets`, `*.pem`, `*.key`

### Before Committing
1. Run `git diff --staged` and scan for sensitive strings
2. Check for patterns like: `token`, `password`, `secret`, `key`, `auth`, `credential`
3. Look for base64-encoded strings or long random alphanumeric sequences

### Fixing Secrets
- Use environment variables: `${SECRET_NAME}` instead of hardcoded values
- Use credential helpers or keychain for passwords
- Keep secrets in separate untracked files and reference them
