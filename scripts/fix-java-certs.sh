#!/usr/bin/env bash
# Import the Netskope CA cert into every writable JDK trust store
# (needed behind the Netskope SSL inspection proxy).

set -uo pipefail

CERT="/Library/Application Support/Netskope/STAgent/data/nscacert.pem"
if [ ! -f "$CERT" ]; then
    echo "[SKIP] Netskope cert not found — not behind SSL inspection proxy"
    exit 0
fi

echo "[CERTS] Importing Netskope CA into JDK trust stores..."

shopt -s nullglob
JDKS=(
    /opt/homebrew/opt/openjdk*/libexec/openjdk.jdk/Contents/Home
    "$HOME"/Library/Java/JavaVirtualMachines/*/Contents/Home
    "$HOME"/Library/Caches/Coursier/jvm/*/Contents/Home
    "$HOME"/Library/Caches/Homebrew/java_cache/*/Contents/Home
)

for jdk in "${JDKS[@]}"; do
    case "$jdk" in /nix/store/*)
        echo "  [SKIP] $jdk (read-only nix store)"
        continue
        ;;
    esac

    CACERTS="$jdk/lib/security/cacerts"
    if [ ! -f "$CACERTS" ] && [ -f "$jdk/jre/lib/security/cacerts" ]; then
        CACERTS="$jdk/jre/lib/security/cacerts"
    fi
    if [ ! -f "$CACERTS" ]; then
        echo "  [SKIP] $jdk (no cacerts)"
        continue
    fi
    if [ ! -w "$CACERTS" ]; then
        echo "  [SKIP] $jdk (cacerts not writable)"
        continue
    fi

    KEYTOOL="$jdk/bin/keytool"
    [ -x "$KEYTOOL" ] || KEYTOOL=keytool

    if "$KEYTOOL" -list -keystore "$CACERTS" -storepass changeit -alias netskope-ca >/dev/null 2>&1; then
        echo "  [OK] $jdk (already imported)"
    elif "$KEYTOOL" -importcert -trustcacerts -alias netskope-ca \
        -file "$CERT" -keystore "$CACERTS" -storepass changeit -noprompt >/dev/null 2>&1; then
        echo "  [OK] $jdk (imported)"
    else
        echo "  [FAIL] $jdk"
    fi
done

echo "[SUCCESS] JDK trust stores updated!"
