#!/usr/bin/env bash
# Builds every library in libraries.txt as <Module>.xcframework.zip plus its checksum.
#
#   Scripts/build.sh <output dir> <path to Provenance-Emu/.github checkout>
#
# Each library is cloned at its pinned ref, its library product is made dynamic, and the
# shared build script does the rest. PV_XCFRAMEWORK_PLATFORMS narrows the platforms for a
# quick local check, e.g. "iOS Simulator".
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$1"
output="$(cd "$1" && pwd)"
tools="$(cd "$2" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# The platforms the apps and shared packages build for. Upstream manifests declare fewer.
export PV_XCFRAMEWORK_PLATFORMS="${PV_XCFRAMEWORK_PLATFORMS:-iOS|iOS Simulator|tvOS|tvOS Simulator|watchOS|watchOS Simulator|visionOS|visionOS Simulator|macOS|macOS,variant=Mac Catalyst}"

while read -r module repository ref; do
    [[ -z "$module" || "$module" == \#* ]] && continue
    checkout="$work/$module"
    git clone --quiet --depth 1 --branch "$ref" "$repository" "$checkout" 2>/dev/null || {
        git clone --quiet "$repository" "$checkout"
        git -C "$checkout" checkout --quiet "$ref"
    }
    # xcodebuild prefers a checked-in Xcode project to the package; only the package is wanted.
    find "$checkout" -maxdepth 1 \( -name '*.xcodeproj' -o -name '*.xcworkspace' \) -exec rm -rf {} +
    # A framework needs a dynamic product; upstream products are automatic. A package can
    # carry several manifests (Package@swift-5.9.swift), so patch whichever SwiftPM picks.
    perl -0pi -e "s/\\.library\\(\\s*name:\\s*\"$module\",\\s*targets:/.library(name: \"$module\", type: .dynamic, targets:/" \
        "$checkout"/Package*.swift
    product_type="$(cd "$checkout" && xcrun swift package dump-package 2>/dev/null \
        | jq -r --arg m "$module" '.products[] | select(.name == $m) | .type.library[0]')"
    [[ "$product_type" == dynamic ]] || {
        echo "$module: could not make its library product dynamic" >&2
        exit 1
    }
    "$tools/scripts/build-xcframework.sh" "$checkout" "$output" "$module"
done < "$root/libraries.txt"
