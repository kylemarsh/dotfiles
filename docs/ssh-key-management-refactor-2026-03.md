# SSH Key Management Refactor (March 2026)

## Problem

Confusion about which SSH key was loaded in the agent. Investigation revealed:

1. **Multiple authentication mechanisms coexisting:**
   - Static RSA key in `~/.ssh/` (permanent, on disk)
   - Ephemeral ECDSA certificate from Smallstep CA (expires every ~16 hours)

2. **The certificate was from employer's infrastructure:**
   - Generated via `step ssh login`
   - Signed by employer's CA
   - Used for employer's internal hosts 
   - Automatically managed via SSH config includes

3. **Original key management code had issues:**
   - Separate `add-personal-keys` and `add-employer-keys` functions
   - Used string matching on key comments
   - Hardcoded key filenames and patterns
   - Machine-type branching logic in `ssh-add-keys`
   - Not fingerprint-based, so couldn't reliably detect if correct key was loaded

## Changes Made

### 1. Added `primary_ssh_key` variable (lines 23-29)

Set near the top of `.zshrc` during machine type detection:

```zsh
# Set primary SSH key based on machine type
if [[ $machine_type =~ ':employer' ]]; then
    primary_ssh_key="$HOME/.ssh/employer.rsa"
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
    primary_ssh_key="$HOME/.ssh/ephemeral"
elif [ -f "$HOME/.ssh/fallback" ]; then
    primary_ssh_key="$HOME/.ssh/fallback"
fi
```

### 2. Created unified `unlock-ssh` function

Replaced `add-personal-keys` and `add-employer-keys` with single function that:

1. Validates `$primary_ssh_key` is set and file exists
2. Gets fingerprint via `ssh-keygen -lf "$primary_ssh_key"`
3. Checks if that fingerprint is in agent via `ssh-add -l | grep -q "$primary_fingerprint"`
4. Only adds key if not already present
5. Adds with 5-day timeout (`-t 432000`)

**Key improvement:** Uses cryptographic fingerprint comparison instead of comment string matching.

### 3. Simplified `ssh-add-keys`

```zsh
function ssh-add-keys {
    unlock-ssh
}
```

No more branching logic - just calls unified function.

### 4. Updated all callsites

- `ssh-start-agent` now calls `unlock-ssh`
- Agent initialization code calls `unlock-ssh`
- `ssh-sync-agent` unchanged (doesn't directly call key loading)

## How It Works Now

**On shell startup:**
1. Machine type detection sets `primary_ssh_key` variable
2. Agent validation checks if ssh-agent is usable
3. If agent works, calls `unlock-ssh` to ensure primary key is loaded
4. `unlock-ssh` checks fingerprint before adding (idempotent)

**Manual usage:**
```bash
# Explicitly load the primary key
unlock-ssh

# Check which keys are loaded
ssh-add -l

# See which key will be used
echo $primary_ssh_key
```

## Benefits

1. **Single source of truth:** `$primary_ssh_key` variable
2. **Fingerprint-based detection:** Cryptographically reliable, not string matching
3. **Idempotent:** Can safely call `unlock-ssh` multiple times
4. **Cross-platform:** Works on macOS (BSD tools) and Linux (GNU tools)
5. **Better error handling:** Validates key file exists before attempting to load
6. **Clearer semantics:** `unlock-ssh` is more intuitive than `add-personal-keys`

## Notes

- **No functionality removed:** Still loads same keys, just more reliably
- **Backward compatible:** Existing workflows unchanged, just better detection

## Technical Details

**Fingerprint format:** `SHA256:base64string`
- Example: `SHA256:7X5IlDT9D4RJPSdsy3OAHCvO8odz88rGNiZpnLqWX30`
- Same format on macOS and Linux (OpenSSH standard)

**Why fingerprints over comments:**
- Comments can be changed without changing the key
- Multiple keys can have same comment
- Fingerprints are cryptographic hashes of the public key material
- Cannot have collisions, uniquely identify the key

**Timeout:** 432000 seconds = 5 days (matches original `add-personal-keys` timeout)
