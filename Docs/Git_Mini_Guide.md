# 📘 Git Мини-Шпаргалка (macOS Terminal)

## 🔹 Инициализация и настройка
```bash
git init                  # Создать новый репозиторий
git clone <url>           # Склонировать существующий репозиторий
git config --global user.name "ТвоёИмя"
git config --global user.email "you@example.com"
```

---

## 🔹 Основной цикл работы
```bash
git status                # Проверить состояние файлов
git add <file>            # Добавить файл в индекс
git add -A                # Добавить все изменения
git commit -m "Сообщение" # Зафиксировать изменения
git push origin main      # Отправить на GitHub
git pull origin main      # Забрать последние изменения с GitHub
```

---

## 🔹 Просмотр истории и различий
```bash
git log --oneline         # История коммитов в одну строку
git diff                  # Разница между изменениями
git diff --staged         # Разница по добавленным в индекс файлам
```

---

## 🔹 Ветки
```bash
git branch                # Список локальных веток
git checkout -b new-branch # Создать и перейти в новую ветку
git checkout main         # Перейти обратно в main
git merge new-branch      # Слить ветку в main
```

---

## 🔹 Синхронизация
```bash
git fetch                 # Получить обновления с GitHub
git log origin/main..main # Локальные коммиты, которых нет на GitHub
git diff origin/main      # Разница локального и удалённого кода
```

---

## 🔹 Отмена изменений
```bash
git restore <file>        # Отменить изменения в файле
git reset --hard HEAD     # Полностью откатиться к последнему коммиту
```

---

💡 **Совет:** чаще всего используй `git status` — это твой лучший навигатор в Git.
