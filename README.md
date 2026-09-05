# Security

This repository contains _Dr_ Max Grossmann’s public keys and references to some supporting tools.

Please see [my main security page](https://max.pm/security/) for more information.

## GnuPG key

Key ID `0x1636BA9B`. Fingerprint `A09A92FC5015EE861A7098511999861C1636BA9B`.

| File | Contents |
| --- | --- |
| [`1636BA9B.asc`](1636BA9B.asc) | Primary public key: Ed25519 signing, with Cv25519 and Kyber encryption subkeys. |
| [`1636BA9B-compat.asc`](1636BA9B-compat.asc) | Compatibility copy without the Kyber subkey, for older GnuPG versions. |
| [`1636BA9B.bin`](1636BA9B.bin) | Binary form of the primary public key. |

## Post-quantum signatures

These keys are for detached file signatures, not encryption.

| Scheme | Status | Public key | Authentication |
| --- | --- | --- | --- |
| SLH-DSA-SHAKE-256s | **Preferred** | [`slhdsa-2026.pem`](slhdsa-2026.pem) | GnuPG signature: [`slhdsa-2026.pem.sig`](slhdsa-2026.pem.sig)<br>Signature over the primary GnuPG key: [`1636BA9B.asc.botansigh`](1636BA9B.asc.botansigh) |
| Dilithium-8x7-r3 | Retained for compatibility | [`dilithium-2026.pem`](dilithium-2026.pem) | GnuPG signature: [`dilithium-2026.pem.sig`](dilithium-2026.pem.sig)<br>Signature over the primary GnuPG key: [`1636BA9B.asc.botansig`](1636BA9B.asc.botansig) |

## Tools

| Directory/file | Purpose |
| --- | --- |
| `botan-slhdsa-signing/` | Botan scripts to generate, store, sign with, and verify SLH-DSA keys. Submodule. |
| `botan-dilithium-signing/` | Equivalent Botan workflow for the Dilithium key. Submodule. |
| `openpgpjs/` | OpenPGP.js, used for browser-based message encryption. Submodule. |
| `check.sh` | Checks prerequisites, file integrity, GPG and Botan signatures, and submodule state. |

## License

This repository is released under CC0 1.0; see [`LICENSE`](LICENSE).
