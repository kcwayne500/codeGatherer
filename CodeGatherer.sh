#!/usr/bin/env bash
# =====================================================
#  CodeGatherer.sh
#  Collects all code files from a target directory into
#  one master file.
# =====================================================

EXTS=("php" "sh" "js" "html" "css" "xml")
C="\033[1;36m"; G="\033[1;32m"; Y="\033[1;33m"; R="\033[1;31m"; N="\033[0m"

echo -e "${C}"
echo "╔═════════════════════════════════════════╗"
echo "║           C O D E  G A T H E R E R      ║"
echo "╚═════════════════════════════════════════╝"
echo -e "${N}"

# ===== require directory argument =====
if [[ -z "$1" || "$1" =~ ^(--help|-h)$ ]]; then
  echo -e "${Y}Usage:${N} ./CodeGatherer.sh <directory> [--recursive] [--only \"pattern\"]"
  echo
  echo "Examples:"
  echo "  ./CodeGatherer.sh /root/uac_system"
  echo "  ./CodeGatherer.sh /var/www --recursive"
  echo "  ./CodeGatherer.sh /srv/code --only \"*.php\""
  echo
  exit 1
fi

# verify directory exists
if [[ -d "$1" ]]; then
  TARGET="${1%/}"
  shift
else
  echo -e "${R}Error:${N} '$1' is not a valid directory."
  echo "Run with --help for usage."
  exit 1
fi

RECURSIVE=0
PATTERN=""

# ===== parse flags =====
while [[ $# -gt 0 ]]; do
  case "$1" in
    --recursive) RECURSIVE=1; shift ;;
    --only) PATTERN="$2"; shift 2 ;;
    *) echo -e "${R}Unknown argument:${N} $1"; exit 1 ;;
  esac
done

OUT="$TARGET/gathered_code_compendium.txt"

echo -e "${G}Target directory:${N} $TARGET"
echo -e "${G}Output file:${N} $OUT"
echo

# remove old output
rm -f "$OUT"

# ===== write header =====
{
  echo "### CODE GATHERER OUTPUT ###"
  echo "# generated: $(date)"
  echo "# directory: $TARGET"
  echo
  echo "===== DIRECTORY STRUCTURE ====="
  if command -v tree &>/dev/null; then
    (cd "$TARGET" && tree -a -I '.git')
  else
    (cd "$TARGET" && find . -type f | sed 's|[^/]*/|   |g')
  fi
  echo
  echo "===== BEGIN FILE CONTENTS ====="
  echo
} > "$OUT"

# ===== find + append files =====
if [[ -n "$PATTERN" ]]; then
  FINDCMD="find \"$TARGET\" $( [[ $RECURSIVE -eq 0 ]] && echo -maxdepth 1 ) -type f -name \"$PATTERN\" ! -path \"*/.*\""
else
  FINDCMD="find \"$TARGET\" $( [[ $RECURSIVE -eq 0 ]] && echo -maxdepth 1 ) -type f \\( $(printf -- '-name \"*.%s\" -o ' "${EXTS[@]}" | sed 's/ -o $//') \\) ! -path \"*/.*\""
fi

eval "$FINDCMD" | while IFS= read -r f; do
  [[ "$f" == "$OUT" ]] && continue
  abs=$(realpath "$f")
  mod=$(stat -c "%y" "$f" 2>/dev/null || stat -f "%Sm" "$f")
  echo -e "${G}Processing:${N} $abs"
  {
    echo "----------------------------------------"
    echo "File: $abs"
    echo "Modified: $mod"
    echo "----------------------------------------"
    cat "$f"
    echo -e "\n"
  } >> "$OUT"
done

# ===== completion =====
echo -e "${C}Done.${N} Output stored in → $OUT"
echo
read -rp "Would you like to view the gathered output now? (y/n): " RESP
if [[ "$RESP" =~ ^[Yy]$ ]]; then
  echo -e "${Y}--- Displaying gathered content ---${N}"
  echo
  cat "$OUT"
  echo
  echo -e "${Y}--- End of gathered content ---${N}"
else
  echo "You can view it later with: cat \"$OUT\""
fi
