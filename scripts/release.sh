#!/bin/bash

# Использование: ./scripts/release.sh v1.14.0 "Добавлен экспорт PDF и прогресс чтения"
VERSION=$1
MESSAGE=$2

if [ -z "$VERSION" ] || [ -z "$MESSAGE" ]; then
  echo "❌ Использование: ./scripts/release.sh vX.Y.Z \"Краткое описание изменений\""
  exit 1
fi

DATE=$(date +%Y-%m-%d)
TAG_DATE=$(date +%Y%m%d)
TAG="$VERSION-$TAG_DATE"

# Добавляем запись в CHANGELOG.md (в начало файла)
CHANGELOG_PATH="Docs/CHANGELOG.md"
TEMP_CHANGELOG=".changelog_temp"

{
  echo "### $VERSION – $DATE"
  echo ""
  echo "- $MESSAGE"
  echo ""
  cat "$CHANGELOG_PATH"
} > "$TEMP_CHANGELOG" && mv "$TEMP_CHANGELOG" "$CHANGELOG_PATH"

# Коммит
git add "$CHANGELOG_PATH"
git commit -m "docs(changelog): $VERSION – $MESSAGE"

# Тег и пуш
git tag "$TAG"
git push origin main --tags

echo "✅ Релиз $VERSION оформлен:"
echo "   • CHANGELOG обновлён"
echo "   • Git-тег: $TAG"

