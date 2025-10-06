#!/bin/bash

set -e

# === 1. Последний тег ===
LAST_TAG=$(git describe --tags --abbrev=0)
COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s")

# === 2. Определение версии ===
# (можно взять из v3, пока делаем патч: v1.13.3)
VERSION=$(echo "$LAST_TAG" | cut -d'-' -f1)
DATE=$(date +%Y-%m-%d)
TAG_DATE=$(date +%Y%m%d)
TAG="${VERSION%.*}.$((${VERSION##*.}+1))-$TAG_DATE"
NEXT_VERSION="${VERSION%.*}.$((${VERSION##*.}+1))"

# === 3. Категоризация коммитов ===
FEATURES=()
FIXES=()
DOCS=()
OTHERS=()

while read -r COMMIT; do
  case "$COMMIT" in
    feat:*) FEATURES+=("$COMMIT") ;;
    feat(*)*) FEATURES+=("$COMMIT") ;;
    fix:*) FIXES+=("$COMMIT") ;;
    fix(*)*) FIXES+=("$COMMIT") ;;
    docs:*) DOCS+=("$COMMIT") ;;
    docs(*)*) DOCS+=("$COMMIT") ;;
    *) OTHERS+=("$COMMIT") ;;
  esac
done <<< "$COMMITS"

# === 4. Генерация CHANGELOG.md ===
TEMP_CHANGELOG=".changelog_temp"
{
  echo "### v$NEXT_VERSION – $DATE"
  echo ""

  if [ ${#FEATURES[@]} -gt 0 ]; then
    echo "#### ✨ Features"
    for f in "${FEATURES[@]}"; do echo "- ${f}"; done
    echo ""
  fi

  if [ ${#FIXES[@]} -gt 0 ]; then
    echo "#### 🐛 Fixes"
    for f in "${FIXES[@]}"; do echo "- ${f}"; done
    echo ""
  fi

  if [ ${#DOCS[@]} -gt 0 ]; then
    echo "#### 📝 Docs"
    for f in "${DOCS[@]}"; do echo "- ${f}"; done
    echo ""
  fi

  if [ ${#OTHERS[@]} -gt 0 ]; then
    echo "#### 🔧 Other"
    for f in "${OTHERS[@]}"; do echo "- ${f}"; done
    echo ""
  fi

  cat Docs/CHANGELOG.md
} > "$TEMP_CHANGELOG" && mv "$TEMP_CHANGELOG" Docs/CHANGELOG.md

# === 5. Git ===
git add Docs/CHANGELOG.md
git commit -m "docs(changelog): автогенерация CHANGELOG для v$NEXT_VERSION"
git tag "v$NEXT_VERSION-$TAG_DATE"
git push
git push --tags

echo "✅ Готово: v$NEXT_VERSION (v$NEXT_VERSION-$TAG_DATE) опубликован."

