# SSH Configuration

SSH client configuration for managing multiple hosts and identities.

## Structure

```
ssh/
├── config          # Main SSH configuration (symlinked to ~/.ssh/config)
└── README.md       # This file
```

## Important

**Do NOT commit SSH keys to this repository!**

Your private keys should be stored in `~/.ssh/` but NOT in the dotfiles repo. The `.gitignore` already excludes:
- `ssh/id_*`
- `ssh/*.pem`
- `ssh/*.key`

## Setup

1. **Generate SSH keys** (if you don't have them):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ssh-keygen -t ed25519 -C "work_email@company.com" -f ~/.ssh/id_ed25519_work
   ```

2. **Add keys to ssh-agent**:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ssh-add ~/.ssh/id_ed25519_work
   ```

3. **Configure your SSH config** at `~/.config/ssh/config`:
   ```ssh
   # Personal GitHub
   Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_ed25519
       AddKeysToAgent yes
       UseKeychain yes

   # Work GitHub
   Host github-work
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_ed25519_work
       AddKeysToAgent yes
       UseKeychain yes
   ```

## Common Patterns

### Multiple GitHub Accounts

```ssh
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
```

Then clone repos with:
```bash
git clone git@github-personal:username/repo.git
git clone git@github-work:company/repo.git
```

### Jump Host / Bastion

```ssh
Host bastion
    HostName bastion.example.com
    User your-username
    IdentityFile ~/.ssh/id_ed25519

Host internal-server
    HostName 10.0.1.50
    User your-username
    ProxyJump bastion
```

### Default Settings

```ssh
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

## macOS Keychain Integration

On macOS, store passphrases in Keychain:

```ssh
Host *
    UseKeychain yes
    AddKeysToAgent yes
```

Then add your key once:
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

## Security Best Practices

1. **Use strong passphrases** on private keys
2. **Use ed25519 keys** (faster, more secure than RSA)
3. **Set proper permissions**:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/config
   chmod 600 ~/.ssh/id_*
   chmod 644 ~/.ssh/id_*.pub
   ```
4. **Use IdentitiesOnly yes** to prevent trying all keys
5. **Never commit private keys** to version control

## Troubleshooting

**Check which key is being used:**
```bash
ssh -vT git@github.com
```

**Test SSH connection:**
```bash
ssh -T git@github.com
```

**List keys in ssh-agent:**
```bash
ssh-add -l
```

**Clear all keys from ssh-agent:**
```bash
ssh-add -D
```

## References

- [GitHub SSH Documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [SSH Config Man Page](https://man.openbsd.org/ssh_config)
