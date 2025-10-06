#!/bin/bash

# === 1. Получение последнего тега ===
LATEST_TAG=$(git describe --tags --abbrev=0)
echo "📌 Последний тег: $LATEST_TAG"

# Извлекаем версию без даты: v1.13.2
VERSION_BASE=$(echo "$LATEST_TAG" | cut -d'-' -f1)
IFS='.' read -r MAJOR MINOR PATCH <<< "${VERSION_BASE#v}"

# === 2. Выбор уровня версии ===
echo "🔢 Выберите тип релиза:"
echo "1) Патч (исправление)   → v$MAJOR.$MINOR.$((PATCH + 1))"
echo "2) Минор (функции)      → v$MAJOR.$((MINOR + 1)).0"
echo "3) Мажор (API/архитектура) → v$((MAJOR + 1)).0.0"
read -p "Ваш выбор (1/2/3): " CHOICE

case $CHOICE in
  1)
    NEXT_VERSION="v$MAJOR.$MINOR.$((PATCH + 1))"
    ;;
  2)
    NEXT_VERSION="v$MAJOR.$((MINOR + 1)).0"
    ;;
  3)
    NEXT_VERSION="v$((MAJOR + 1)).0.0"
    ;;
  *)
    echo "❌ Неверный выбор"; exit 1 ;;
esac

DATE=$(date +%Y-%m-%d)
TAG_DATE=$(date +%Y%m%d)
TAG="$NEXT_VERSION-$TAG_DATE"
echo "🏷 Тег: $TAG"

# === 3. Генерация CHANGELOG ===
TEMP_CHANGELOG=".changelog_temp"
COMMITS=$(git log "${LATEST_TAG}..HEAD" --pretty=format:"%s")

echo "📄 Генерация CHANGELOG..."

{
  echo "### $NEXT_VERSION – $DATE"
  echo ""

  echo "$COMMITS" | grep -E "^feat" | sed 's/^/- ✨ /' && echo ""
  echo "$COMMITS" | grep -E "^fix"  | sed 's/^/- 🛠 /' && echo ""
  echo "$COMMITS" | grep -E "^docs" | sed 's/^/- 📝 /' && echo ""
  echo "$COMMITS" | grep -E "^chore" | sed 's/^/- 🔧 /' && echo ""
  echo "$COMMITS" | grep -E "^refactor" | sed 's/^/- 🧱 /' && echo ""
  echo "$COMMITS" | grep -E "^test" | sed 's/^/- 🧪 /' && echo ""

  echo ""
  cat Docs/CHANGELOG.md
} > "$TEMP_CHANGELOG" && mv "$TEMP_CHANGELOG" Docs/CHANGELOG.md

# === 4. Коммит, тег и пуш ===
git add Docs/CHANGELOG.md
git commit -m "docs(changelog): автогенерация CHANGELOG для $NEXT_VERSION"
git tag "$TAG"
git push
git push --tags

echo "✅ Готово: $NEXT_VERSION ($TAG) опубликован."

