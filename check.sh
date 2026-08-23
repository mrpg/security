#!/usr/bin/env bash
set -euo pipefail

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); echo "PASS: $1"; }
fail() { FAIL=$((FAIL+1)); echo "FAIL: $1" >&2; }

FP="A09A92FC5015EE861A7098511999861C1636BA9B"
KEYID="1636BA9B"

# --- Prerequisites ---
for bin in gpg botan; do
    command -v "$bin" >/dev/null 2>&1 || { fail "$bin not in PATH"; exit 1; }
done
ok "gpg and botan available"

# --- Submodules ---
git submodule status --recursive | while read -r line; do
    if [[ "$line" == -* ]]; then
        echo "FAIL: uninitialized submodule: $line" >&2
        exit 1
    fi
done || { fail "submodules not fully initialized (run git submodule update --init --recursive)"; exit 1; }
ok "all submodules initialized"

# --- Required files exist ---
for f in 1636BA9B.asc 1636BA9B-compat.asc 1636BA9B.bin \
         1636BA9B.asc.botansig 1636BA9B.asc.botansigh \
         dilithium-2026.pem dilithium-2026.pem.sig \
         slhdsa-2026.pem slhdsa-2026.pem.sig; do
    if [ -s "$f" ]; then
        ok "$f exists and non-empty"
    else
        fail "$f missing or empty"
    fi
done

# --- GnuPG key: fingerprint ---
got_fp=$(gpg --with-colons --import-options show-only --import 1636BA9B.asc 2>/dev/null \
         | awk -F: '/^fpr:/{print $10; exit}')
if [ "$got_fp" = "$FP" ]; then
    ok "1636BA9B.asc fingerprint matches $KEYID"
else
    fail "fingerprint mismatch: expected $FP, got $got_fp"
fi

# --- GnuPG key: expected subkeys ---
subkeys=$(gpg --with-colons --import-options show-only --import 1636BA9B.asc 2>/dev/null \
          | grep -c '^sub:')
if [ "$subkeys" -ge 2 ]; then
    ok "1636BA9B.asc has $subkeys subkeys (cv25519 + kyber)"
else
    fail "expected >=2 subkeys, got $subkeys"
fi

# --- Compat key: same primary, no Kyber subkey ---
compat_fp=$(gpg --with-colons --import-options show-only --import 1636BA9B-compat.asc 2>/dev/null \
            | awk -F: '/^fpr:/{print $10; exit}')
if [ "$compat_fp" = "$FP" ]; then
    ok "compat key same primary fingerprint"
else
    fail "compat key fingerprint mismatch"
fi

compat_subs=$(gpg --with-colons --import-options show-only --import 1636BA9B-compat.asc 2>/dev/null \
              | grep -c '^sub:')
if [ "$compat_subs" -eq 1 ]; then
    ok "compat key has 1 subkey (no Kyber)"
else
    fail "compat key has $compat_subs subkeys, expected 1"
fi

# --- Binary key matches armored key ---
if gpg --dearmor < 1636BA9B.asc 2>/dev/null | cmp -s - 1636BA9B.bin; then
    ok "1636BA9B.bin matches dearmored 1636BA9B.asc"
else
    fail "1636BA9B.bin does not match 1636BA9B.asc"
fi

# --- PEM public keys have valid structure ---
for pem in dilithium-2026.pem slhdsa-2026.pem; do
    if head -1 "$pem" | grep -q "BEGIN PUBLIC KEY"; then
        ok "$pem has PEM public key header"
    else
        fail "$pem missing PEM header"
    fi
done

# --- GPG detached signatures over PEM keys ---
_tmpdir=$(mktemp -d)
trap 'rm -rf "$_tmpdir"' EXIT
gpg --homedir "$_tmpdir" --no-autostart --import 1636BA9B.asc 2>/dev/null

for pem in dilithium-2026.pem slhdsa-2026.pem; do
    sig="${pem}.sig"
    signer=$(gpg --homedir "$_tmpdir" --no-autostart \
             --status-fd 1 --verify "$sig" "$pem" 2>/dev/null \
             | awk '/GOODSIG/{found=1} /VALIDSIG/{print $3; exit}')
    if [ "$signer" = "$FP" ]; then
        ok "$sig valid GPG signature by $KEYID"
    else
        fail "$sig GPG verification failed (signer=$signer)"
    fi
done

# --- Botan cross-signatures: PQ keys signed the GnuPG key ---
if botan verify --hash="" dilithium-2026.pem 1636BA9B.asc 1636BA9B.asc.botansig 2>/dev/null \
    | grep -q "Signature is valid"; then
    ok "Dilithium signature over 1636BA9B.asc valid"
else
    fail "Dilithium signature over 1636BA9B.asc INVALID"
fi

if botan verify --hash="" slhdsa-2026.pem 1636BA9B.asc 1636BA9B.asc.botansigh 2>/dev/null \
    | grep -q "Signature is valid"; then
    ok "SLH-DSA signature over 1636BA9B.asc valid"
else
    fail "SLH-DSA signature over 1636BA9B.asc INVALID"
fi

# --- Submodule scripts exist and are executable ---
for sub in botan-dilithium-signing botan-slhdsa-signing; do
    for script in genkey.sh sign.sh verify.sh test.sh; do
        if [ -f "$sub/$script" ]; then
            ok "$sub/$script exists"
        else
            fail "$sub/$script missing"
        fi
    done
done
if [ -d openpgpjs-with-kyber/src ]; then
    ok "openpgpjs-with-kyber/src present"
else
    fail "openpgpjs-with-kyber/src missing"
fi

# --- Submodule branches ---
dil_branch=$(git -C botan-dilithium-signing rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$dil_branch" = "master" ]; then
    ok "botan-dilithium-signing on master"
else
    fail "botan-dilithium-signing on $dil_branch, expected master"
fi

slh_branch=$(git -C botan-slhdsa-signing rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$slh_branch" = "master" ]; then
    ok "botan-slhdsa-signing on master"
else
    fail "botan-slhdsa-signing on $slh_branch, expected master"
fi

kyber_branch=$(git -C openpgpjs-with-kyber rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$kyber_branch" = "kyber" ]; then
    ok "openpgpjs-with-kyber on kyber"
else
    fail "openpgpjs-with-kyber on $kyber_branch, expected kyber"
fi

# --- Summary ---
echo
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
