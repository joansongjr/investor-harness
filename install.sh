#!/usr/bin/env bash
#
# Investor Harness · One-liner install (curl entry)
# https://github.com/joansongjr/investor-harness
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/joansongjr/investor-harness/main/install.sh | bash
#
# Or with custom install location:
#   curl -fsSL https://raw.githubusercontent.com/joansongjr/investor-harness/main/install.sh | bash -s -- --dir ~/my-harness
#
# What it does:
#   1. Clones investor-harness to ~/investor-harness (or --dir path)
#   2. Runs setup.sh (the interactive wizard) from the cloned dir

set -euo pipefail

REPO_URL="https://github.com/joansongjr/investor-harness.git"
DEFAULT_DIR="$HOME/investor-harness"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# Parse args
INSTALL_DIR="$DEFAULT_DIR"
while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: curl -fsSL .../install.sh | bash [-- --dir PATH]"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

echo
echo "════════════════════════════════════════════════════════════"
echo "  ${BOLD}Investor Harness · One-liner Install${NC}"
echo "════════════════════════════════════════════════════════════"
echo

# Check dependencies
if ! command -v git >/dev/null 2>&1; then
  echo "${RED}✗${NC} git is not installed. Please install git first."
  echo "  macOS:   xcode-select --install"
  echo "  Linux:   sudo apt install git / sudo yum install git"
  exit 1
fi

# Existing dir?
if [ -d "$INSTALL_DIR" ]; then
  if [ -d "$INSTALL_DIR/.git" ]; then
    echo "${YELLOW}⚠${NC} $INSTALL_DIR 已存在且是 git 仓库"
    echo "  如果要更新，跑: cd $INSTALL_DIR && bash update.sh"
    echo "  如果要重装，先删除: rm -rf $INSTALL_DIR"
    exit 1
  else
    echo "${RED}✗${NC} $INSTALL_DIR 已存在但不是 git 仓库"
    echo "  请先处理这个目录或选择其他位置："
    echo "  curl -fsSL .../install.sh | bash -s -- --dir ~/other-path"
    exit 1
  fi
fi

echo "  克隆到: $INSTALL_DIR"
echo

# Clone
git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
echo

# Run setup.sh
echo "${GREEN}✓${NC} 克隆完成"
echo
echo "  接下来进入交互式安装向导..."
echo

cd "$INSTALL_DIR"
bash setup.sh
