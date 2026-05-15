# AGENTS.md

## Build Artifacts and Worktrees

SwiftPM writes build artifacts to `native/MuesliNative/.build` inside the active worktree by default. That can consume several GB per worktree when multiple feature worktrees are used.

For local app builds, set `MUESLI_SWIFTPM_SCRATCH_PATH` so `scripts/build_native_app.sh` passes a shared `--scratch-path` to SwiftPM:

```bash
MUESLI_SWIFTPM_SCRATCH_PATH="$HOME/Library/Caches/muesli-spm/dev" ./scripts/dev-test.sh
MUESLI_SWIFTPM_SCRATCH_PATH="$HOME/Library/Caches/muesli-spm/preprod" ./scripts/build_native_app.sh release
```

Caveat: do not run concurrent builds from different worktrees into the same scratch path. Use separate paths per channel, agent, or simultaneous build, such as `dev`, `preprod`, `test`, or `agent-1`.

Deleting a scratch path only removes rebuildable SwiftPM artifacts. It does not delete installed app bundles or app data under `~/Library/Application Support/`.

For direct SwiftPM test runs, pass the scratch path yourself:

```bash
swift test --package-path native/MuesliNative --scratch-path "$HOME/Library/Caches/muesli-spm/test"
```

## Dev App Signing and macOS Permissions

For Sam's local `/Applications/MuesliDev.app`, do not set `MUESLI_SKIP_SIGN=1` when rebuilding. macOS privacy permissions are tied to the app's bundle identifier plus signing requirement; unsigned/ad-hoc rebuilds get a changing code hash and can force Microphone, Accessibility, Input Monitoring, Calendar, or Screen Recording permissions to be granted again.

Use the stable local signing identity instead:

```bash
MUESLI_SWIFTPM_SCRATCH_PATH="$HOME/Library/Caches/muesli-spm/dev-integration" ./scripts/dev-test.sh
```

`scripts/dev-test.sh` automatically uses the `Muesli Local Dev Signing` identity when it is present. Verify it with:

```bash
security find-identity -v -p codesigning | grep -F "Muesli Local Dev Signing"
codesign -dvvv /Applications/MuesliDev.app 2>&1 | grep -E "Authority|Signature"
```

Only use `MUESLI_SKIP_SIGN=1` on contributor machines that do not have a signing identity. If the dev app was accidentally rebuilt unsigned, rebuild it once with the signed command above, re-grant any permissions macOS asks for, and future signed rebuilds should preserve those permissions. Do not run `scripts/dev-reset-permissions.sh` or wipe `~/Library/Application Support/MuesliDev` unless the user explicitly asks.
