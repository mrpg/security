# Security

This repository contains _Dr_ Max Grossmann’s public keys and references to some supporting tools.

Please see [my main security page](https://max.pm/security/) for more information.

## GnuPG key

Key ID `0x1636BA9B`. Fingerprint `A09A92FC5015EE861A7098511999861C1636BA9B`.

| File | Contents |
| --- | --- |
| [`1636BA9B.asc`](1636BA9B.asc) | Primary public key: Ed25519 signing, with Cv25519 and Kyber/ML-KEM encryption subkeys. |
| [`1636BA9B-compat.asc`](1636BA9B-compat.asc) | Compatibility copy without the Kyber/ML-KEM subkeys, for older GnuPG versions. |
| [`1636BA9B.bin`](1636BA9B.bin) | Binary form of the primary public key. |

## Future OpenPGP v6 key

Fingerprint `C1E8235A94BE2427043C08EEF79F9481E44A587ACC5B0D2631BE34C3A8B949BC`. This key is not yet in use; please keep using `0x1636BA9B` for now.

| File | Contents |
| --- | --- |
| [`future/C1E8235A94BE2427.asc`](future/C1E8235A94BE2427.asc) | RFC 9580 v6 public key with RFC 9980 post-quantum hybrid algorithms: ML-DSA-87+Ed448 primary key (certification only), ML-DSA-87+Ed448 signing and authentication subkeys, and an ML-KEM-1024+X448 encryption subkey. The user ID is certified by `0x1636BA9B`. |

Few OpenPGP implementations support this key yet. GnuPG cannot import it: version 2.4.7 cannot parse it, and version 2.5.24 can parse it but not import it. It works with [Sequoia](https://sequoia-pgp.org/) built with its [OpenSSL backend](https://sequoia-pgp.org/blog/2025/11/15/202511-post-quantum-cryptography/), [rPGP](https://github.com/rpgp/rpgp) with its `pqc` feature, [GopenPGP](https://github.com/ProtonMail/gopenpgp), and software based on [Bouncy Castle](https://www.bouncycastle.org/), such as [PGPony](https://f-droid.org/packages/com.pgpony.android/).

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
