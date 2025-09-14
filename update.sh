#
//  update.sh
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//
#!/bin/bash
# Автоматическое сохранение проекта на GitHub

if [ -z "$1" ]; then
  echo "Использование: ./update.sh \"Сообщение коммита\""
  exit 1
fi

# Переходим в папку скрипта
cd "$(dirname "$0")" || exit 1

# Подтягиваем последние изменения
git pull --rebase origin main

# Добавляем все изменения
git add .

# Делаем коммит
git commit -m "$1"

# Отправляем на GitHub
git push origin main

