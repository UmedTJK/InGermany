#!/bin/bash

set -e

# === 1. Найти последний тег ===
LAST_TAG=$(git describe --tags --abbrev=0)
echo "📌 Последний тег: $LAST_TAG"

# === 2. Список коммитов с момента последнего тега ===
COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s")

# === 3. Вычислить следующую версию (только патч для простоты) ===
BASE_VERSION=$(echo "$LAST_TAG" | cut -d'-' -f1)
MAJOR=$(echo "$BASE_VERSION" | cut -d. -f1 | sed 's/v//')
MINOR=$(echo "$BASE_VERSION" | cut -d. -f2)
PATCH=$(echo "$BASE_VERSION" | cut -d. -f3)
NEXT_PATCH=$((PATCH + 1))
NEXT_VERSION="v$MAJOR.$MINOR.$NEXT_PATCH"

# === 4. Дата ===
DATE=$(date +%Y-%m-%d)
TAG_DATE=$(date +%Y%m%d)
TAG="$NEXT_VERSION-$TAG_DATE"

echo "🔢 Новая версия: $NEXT_VERSION"
echo "🏷 Тег: $TAG"

# === 5. Категоризация коммитов ===
FEATURES=()
FIXES=()
DOCS=()
OTHERS=()

while read -r COMMIT; do
  if [[ "$COMMIT" == feat* ]]; then
    FEATURES+=("$COMMIT")
  elif [[ "$COMMIT" == fix* ]]; then
    FIXES+=("$COMMIT")
  elif [[ "$COMMIT" == docs* ]]; then
    DOCS+=("$COMMIT")
  else
    OTHERS+=("$COMMIT")
  fi
done <<< "$COMMITS"

# === 6. Формирование нового блока CHANGELOG ===
TEMP_CHANGELOG=".changelog_temp"
{
  echo "### $NEXT_VERSION – $DATE"
  echo ""

  if [ ${#FEATURES[@]} -gt 0 ]; then
    echo "#### ✨ Features"
    for f in "${FEATURES[@]}"; do echo "- $f"; done
    echo ""
  fi

  if [ ${#FIXES[@]} -gt 0 ]; then
    echo "#### 🐛 Fixes"
    for f in "${FIXES[@]}"; do echo "- $f"; done
    echo ""
  fi

  if [ ${#DOCS[@]} -gt 0 ]; then
    echo "#### 📝 Docs"
    for f in "${DOCS[@]}"; do echo "- $f"; done
    echo ""
  fi

  if [ ${#OTHERS[@]} -gt 0 ]; then
    echo "#### 🔧 Other"
    for f in "${OTHERS[@]}"; do echo "- $f"; done
    echo ""
  fi

  cat Docs/CHANGELOG.md
} > "$TEMP_CHANGELOG" && mv "$TEMP_CHANGELOG" Docs/CHANGELOG.md

# === 7. Коммит, тег и пуш ===
git add Docs/CHANGELOG.md
git commit -m "docs(changelog): автогенерация CHANGELOG для $NEXT_VERSION"
git tag "$TAG"
git push
git push --tags

echo "✅ Готово: $NEXT_VERSION ($TAG) опубликован."

