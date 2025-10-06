#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "❌ Пожалуйста, укажи версию. Пример: ./scripts/tag_with_date.sh v1.12.0"
  exit 1
fi

DATE=$(date +%Y%m%d)
TAG="$VERSION-$DATE"

git tag "$TAG"
git push origin "$TAG"

echo "✅ Добавлен тег: $TAG"

