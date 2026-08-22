#!/usr/bin/env bash
# Print the state key for a target, using the SAME derivation the
# start/resume/reset/show scripts use (target_key in _common.sh).
# Callers that need to locate a state file by hand (e.g. TRIP-3-release
# promoting a converged review) must go through this rather than
# re-deriving the key inline — an inline `realpath | sed` misses the
# checksum suffix and silently fails to find the file.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

if [ $# -ne 1 ]; then
    echo "usage: key.sh <target>" >&2
    exit 64
fi

target_key "$1"
