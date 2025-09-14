#!/bin/bash
# Автоматическое сохранение проекта на GitHub

if [ -z "$1" ]; then
  echo "Использование: ./update.sh \"Сообщение коммита\""
  exit 1
fi

cd "$(dirname "$0")" || exit 1

git add .
git commit -m "$1"
git push origin main

echo "✅ Проект сохранён и отправлен на GitHub."
