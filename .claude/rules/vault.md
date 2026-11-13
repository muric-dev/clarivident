---
paths:
  - "internal/vault/**"
---

# Vault rules

- Encrypt with AES-256-GCM through `cipher.NewGCMWithRandomNonce`. No manual nonces and no custom primitives.
- AAD is the 4-byte big-endian `len(bucket)`, then `bucket`, then `key`, on every seal and open, so a moved or swapped record fails to decrypt. Never a bare concatenation: `("ab","c")` and `("a","bc")` must produce different AAD.
- The key is 32 bytes from `crypto/rand`, kept in the macOS Keychain. Only `internal/platform` imports go-keyring and exposes `KeyGet` and `KeySet` on `Platform`; the vault takes a `Platform` and tests use a fake, never the real Keychain. Never log it, write it to disk, or pass it on argv.
- `vault.db` lives in `~/Library/Application Support/clarivident/` with mode `0600`. The bbolt timestamp key is the only plaintext; no path or size outside the ciphertext.
- The vault is the only writer in the program, and it writes only inside that directory. The directory is `0700`, its path is a constant from `internal/platform`, and it is never built from a scanned or user-supplied path.
- Compress with `compress/flate` before encrypting.
- Limits: 50 MB total. Full samples for 90 days, then daily min/max. All snapshots for 30 days, then one per day up to a year.
- Required tests: an altered byte fails, a moved record fails, a record sealed under `("a","bc")` does not open as `("ab","c")`, a wrong key fails, and a known path never appears in the raw `vault.db`.
- Crypto, key, and store changes get `/security-review` before shipping.
