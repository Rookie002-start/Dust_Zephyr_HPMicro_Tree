#!/usr/bin/env bash
# Apply the HPM changes to clean community SDK checkouts.
# Zephyr itself is patched by the sibling Dust_Zephyr_Tree repository.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES="$ROOT/zephyr-patches"

SDK_ENV="$ROOT/../sdk_env"
SDK_GLUE="$ROOT/../sdk_glue"
CHERRYUSB=""
CHECK_ONLY=0

usage() {
  cat <<'EOF'
Usage: apply-patches.sh [options]

Options:
  --sdk-env <checkout>   sdk_env checkout (default: ../sdk_env)
  --sdk-glue <checkout>  zephyr_sdk_glue checkout (default: ../sdk_glue)
  --cherryusb <path>     Optional CherryUSB checkout
  --check                Check applicability without modifying checkouts
  -h, --help             Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sdk-env)   SDK_ENV="$2";   shift 2 ;;
    --sdk-glue)  SDK_GLUE="$2";  shift 2 ;;
    --cherryusb) CHERRYUSB="$2"; shift 2 ;;
    --check)     CHECK_ONLY=1;   shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage >&2; exit 2 ;;
  esac
done

for repo in "$SDK_ENV" "$SDK_GLUE"; do
  if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "不是 Git 仓库: $repo" >&2
    exit 1
  fi
done

apply_one() {
  local repo="$1" patch="$2"

  if git -C "$repo" apply --reverse --check "$patch" >/dev/null 2>&1; then
    echo "already applied: $(basename "$patch")"
    return
  fi

  git -C "$repo" apply --check "$patch"
  if [[ "$CHECK_ONLY" -eq 1 ]]; then
    echo "applicable: $(basename "$patch")"
    return
  fi

  git -C "$repo" apply "$patch"
  echo "applied: $(basename "$patch")"
}

apply_dir() {
  local repo="$1" dir="$2"
  shopt -s nullglob
  local patches=("$dir"/*.diff)
  shopt -u nullglob

  if [[ ${#patches[@]} -eq 0 ]]; then
    echo "没有找到补丁: $dir" >&2
    exit 1
  fi

  local patch
  for patch in "${patches[@]}"; do
    apply_one "$repo" "$patch"
  done
}

apply_dir "$SDK_ENV"  "$PATCHES/sdk_env"
apply_dir "$SDK_GLUE" "$PATCHES/sdk_glue"

if [[ -n "$CHERRYUSB" ]]; then
  if ! git -C "$CHERRYUSB" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "不是 Git 仓库: $CHERRYUSB" >&2
    exit 1
  fi
  apply_dir "$CHERRYUSB" "$PATCHES/cherryusb"
fi

echo "HPM 社区仓库补丁处理完成。Zephyr 补丁请运行 Dust_Zephyr_Tree/patches/apply-zephyr-patches.sh。"
