#!/usr/bin/env bash
# Run from the directory that should contain ImSwitchOPT, or from the repo itself.
set -euo pipefail

archive_url="https://github.com/QBioImaging/ImSwitchOPT/archive/refs/heads/master.zip"
download_dir=""
trap 'if [[ -n "$download_dir" ]]; then rm -rf -- "$download_dir"; fi' EXIT

if [[ "${PWD##*/}" == "ImSwitchOPT" && -d imswitch && -f requirements.lock ]]; then
    project_dir="$PWD"
else
    project_dir="$PWD/ImSwitchOPT"
fi

if [[ ! -d "$project_dir" ]]; then
    if [[ -e "$project_dir" ]]; then
        echo "Error: $project_dir exists but is not a directory." >&2
        exit 1
    fi
    for command in curl unzip; do
        if ! command -v "$command" >/dev/null 2>&1; then
            echo "Error: $command must be installed first." >&2
            exit 1
        fi
    done
    # Keep extraction on the same filesystem as the destination.
    download_dir="$(mktemp -d "$PWD/.imswitch-download.XXXXXX")"
    echo "Downloading ImSwitchOPT..."
    curl -fL --retry 3 "$archive_url" -o "$download_dir/master.zip"
    unzip -q "$download_dir/master.zip" -d "$download_dir"
    mv "$download_dir/ImSwitchOPT-master" "$project_dir"
fi

cd "$project_dir"
if [[ ! -d imswitch || ! -f requirements.lock ]]; then
    echo "Error: $project_dir does not contain imswitch and requirements.lock." >&2
    exit 1
fi

# Prefer the project's existing environment when one is available.
if [[ -f .venv/bin/activate ]]; then
    source .venv/bin/activate
fi

echo "Trying to launch ImSwitch..."
if command -v python >/dev/null 2>&1 && python -m imswitch "$@"; then
    exit 0
fi

echo "Launch failed. Setting up ImSwitch with Python 3.10..."
# Include uv's default install directory, including on subsequent script runs.
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl must be installed first." >&2
        exit 1
    fi
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

uv venv --python 3.10
source .venv/bin/activate
uv pip install --python "$PWD/.venv/bin/python" -r requirements.lock
python -m imswitch "$@"
