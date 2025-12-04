# Git Configuration

Multi-identity git configuration using conditional includes based on directory paths.

## How It Works

The main `.gitconfig` file uses `includeIf` directives to automatically load different configurations based on which directory you're working in:

- `~/work/**` → Uses `.gitconfig-work`
- `~/work/phare/**` → Uses `.gitconfig-phare`
- `~/work/palantir/**` → Uses `.gitconfig-palantir`
- `~/personal/**` → Uses `.gitconfig-codeberg`
- `~/.config/**` → Uses `.gitconfig-codeberg`

## Setup

1. **Copy the example templates:**
   ```bash
   cp git/.gitconfig-personal.example git/.gitconfig-personal
   cp git/.gitconfig-work.example git/.gitconfig-work
   cp git/.gitconfig-codeberg.example git/.gitconfig-codeberg
   ```

2. **Edit each file with your information:**
   ```bash
   nvim ~/.config/git/.gitconfig-personal
   ```

3. **Add your details:**
   - `email`: Your email address for this identity
   - `name`: Your full name
   - `signingkey`: Your GPG key ID (if using signed commits)

## Git Aliases

The configuration includes custom aliases for managing multiple remotes:

### push-github
Pushes to GitHub with personal identity. Requires environment variables:
```bash
export GIT_PERSONAL_EMAIL="your@email.com"
export GIT_PERSONAL_KEY="YOUR_GPG_KEY_ID"
```

### push-codeberg
Pushes to Codeberg with codeberg identity. Requires:
```bash
export GIT_CODEBERG_EMAIL="your@codeberg.email"
export GIT_CODEBERG_KEY="YOUR_GPG_KEY_ID"
```

### push-all
Pushes to both remotes with appropriate identities.

## Additional Features

- **GPG Signing**: Commits are signed by default (`commit.gpgsign = true`)
- **Rerere**: Reuse recorded resolution for merge conflicts
- **Default Branch**: `main` instead of `master`

## Troubleshooting

**Check which config is active:**
```bash
git config user.email
git config user.name
```

**Test conditional includes:**
```bash
cd ~/personal/myproject
git config --show-origin user.email
```

**List all git configs:**
```bash
git config --list --show-origin
```
