#!/bin/bash

# === CONFIG ===
CHANGELOG_PATH="Docs/CHANGELOG.md"
BRANCH="main"

# === 1. Определение последней версии ===
LAST_VERSION=$(git tag --sort=-creatordate | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | head -n 1)

if [ -z "$LAST_VERSION" ]; then
  LAST_VERSION="v0.0.0"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_VERSION#v}"
NEXT_MAJOR=$((MAJOR + 1))
NEXT_MINOR=$((MINOR + 1))
NEXT_PATCH=$((PATCH + 1))

# === 2. Предложение следующей версии ===
echo "📌 Последняя версия: $LAST_VERSION"
echo "🔢 Возможные варианты:"
echo "   1) Патч   → v$MAJOR.$MINOR.$NEXT_PATCH"
echo "   2) Minor  → v$MAJOR.$NEXT_MINOR.0"
echo "   3) Major  → v$NEXT_MAJOR.0.0"
read -p "Выбери (1/2/3): " CHOICE

case $CHOICE in
  1) VERSION="v$MAJOR.$MINOR.$NEXT_PATCH" ;;
  2) VERSION="v$MAJOR.$NEXT_MINOR.0" ;;
  3) VERSION="v$NEXT_MAJOR.0.0" ;;
  *) echo "❌ Неверный выбор"; exit 1 ;;
esac

read -p "📝 Введи краткое описание изменений: " MESSAGE

# === 3. Генерация тега с датой ===
DATE=$(date +%Y-%m-%d)
TAG_DATE=$(date +%Y%m%d)
TAG="$VERSION-$TAG_DATE"

# === 4. Обновление CHANGELOG.md ===
TEMP_CHANGELOG=".changelog_temp"

{
  echo "### $VERSION – $DATE"
  echo ""
  echo "- $MESSAGE"
  echo ""
  cat Docs/CHANGELOG.md
} > "$TEMP_CHANGELOG" && mv "$TEMP_CHANGELOG" Docs/CHANGELOG.md

# === 5. Коммит и тег ===
git add Docs/CHANGELOG.md
git commit -m "$MESSAGE"
git tag "$TAG"
git push
git push --tags

