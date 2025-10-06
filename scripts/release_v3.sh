#!/bin/bash

# === 1. Получение последнего тега и версии ===
LAST_TAG=$(git describe --tags --abbrev=0)
LAST_VERSION=${LAST_TAG%-*}
DATE=$(date +%Y-%m-%d)
TAG_DATE=$(date +%Y%m%d)

echo "📌 Последняя версия: $LAST_VERSION"

# === 2. Вычисление следующей версии ===
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_VERSION#v}"
NEXT_PATCH=$((PATCH + 1))
NEXT_VERSION="v$MAJOR.$MINOR.$NEXT_PATCH"
TAG="$NEXT_VERSION-$TAG_DATE"

echo "🔢 Следующая версия: $NEXT_VERSION"

# === 3. Извлечение коммитов с последнего тега ===
COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s")

# === 4. Категоризация коммитов ===
FEATURES=""
FIXES=""
DOCS=""
REFACTOR=""
CHORE=""
TESTS=""
STYLE=""

while IFS= read -r COMMIT; do
  if [[ $COMMIT == feat:* ]]; then
    FEATURES+="\\n- ${COMMIT}"
  elif [[ $COMMIT == fix:* ]]; then
    FIXES+="\\n- ${COMMIT}"
  elif [[ $COMMIT == docs:* ]]; then
    DOCS+="\\n- ${COMMIT}"
  elif [[ $COMMIT == refactor:* ]]; then
    REFACTOR+="\\n- ${COMMIT}"
  elif [[ $COMMIT == chore:* ]]; then
    CHORE+="\\n- ${COMMIT}"
  elif [[ $COMMIT == test:* ]]; then
    TESTS+="\\n- ${COMMIT}"
  elif [[ $COMMIT == style:* ]]; then
    STYLE+="\\n- ${COMMIT}"
  fi
done <<< "$COMMITS"

# === 5. Генерация блока CHANGELOG ===
TEMP_CHANGELOG=".changelog_temp"

{
  echo "### $NEXT_VERSION – $DATE"
  echo ""
  [[ -n "$FEATURES" ]] && echo -e "#### 🟢 Features$FEATURES\\n"
  [[ -n "$FIXES" ]] && echo -e "#### 🔧 Fixes$FIXES\\n"
  [[ -n "$DOCS" ]] && echo -e "#### 📄 Documentation$DOCS\\n"
  [[ -n "$REFACTOR" ]] && echo -e "#### ♻️ Refactoring$REFACTOR\\n"
  [[ -n "$CHORE" ]] && echo -e "#### 🧹 Chores$CHORE\\n"
  [[ -n "$TESTS" ]] && echo -e "#### ✅ Tests$TESTS\\n"
  [[ -n "$STYLE" ]] && echo -e "#### 🎨 Style$STYLE\\n"
  echo ""
  cat Docs/CHANGELOG.md
} > "$TEMP_CHANGELOG" && mv "$TEMP_CHANGELOG" Docs/CHANGELOG.md

# === 6. Коммит, тег и пуш ===
git add Docs/CHANGELOG.md
git commit -m "docs(changelog): обновлён CHANGELOG для $NEXT_VERSION"
git tag "$TAG"
git push
git push --tags

echo "✅ Готово: $NEXT_VERSION ($TAG) опубликован."

