#!/bin/zsh
set -e

echo "🚀 Starting release script..."

# Находим последний релизный тег (учитываем только vX.Y.Z)
LAST_TAG=$(git tag | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)

if [ -z "$LAST_TAG" ]; then
  echo "⚠️  Нет существующих тегов. Начинаем с v1.0.0"
  LAST_TAG="v1.0.0"
fi

echo "📌 Последняя версия: $LAST_TAG"

# Извлекаем MAJOR, MINOR, PATCH
VERSION=$(echo $LAST_TAG | sed -E 's/^v([0-9]+)\.([0-9]+)\.([0-9]+).*/\1 \2 \3/')
set -- $VERSION
MAJOR=$1
MINOR=$2
PATCH=$3

# Показываем варианты
echo "🔢 Возможные варианты:"
echo "   1) Патч   → v$MAJOR.$MINOR.$((PATCH+1))"
echo "   2) Минор  → v$MAJOR.$((MINOR+1)).0"
echo "   3) Мажор  → v$((MAJOR+1)).0.0"

read "choice?Выбери (1/2/3): "

case $choice in
  1) NEW_TAG="v$MAJOR.$MINOR.$((PATCH+1))-$(date +%Y%m%d)" ;;
  2) NEW_TAG="v$MAJOR.$((MINOR+1)).0-$(date +%Y%m%d)" ;;
  3) NEW_TAG="v$((MAJOR+1)).0.0-$(date +%Y%m%d)" ;;
  *) echo "❌ Неверный выбор"; exit 1 ;;
esac

echo "📝 Введи краткое описание изменений:"
read desc

# Обновляем CHANGELOG.md
echo "" >> Docs/CHANGELOG.md
echo "## $NEW_TAG – $(date +%Y-%m-%d)" >> Docs/CHANGELOG.md
echo "" >> Docs/CHANGELOG.md
echo "$desc" >> Docs/CHANGELOG.md
echo "" >> Docs/CHANGELOG.md

# Добавляем в git
git add Docs/CHANGELOG.md
git commit -m "docs(changelog): update for $NEW_TAG"
git tag $NEW_TAG
git push origin main --tags

echo "✅ Новый релиз создан: $NEW_TAG"

