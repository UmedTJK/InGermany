# Git Snapshot · InGermany

Дата снимка: 2025-09-25

## Текущая ветка
- feature/article-images (HEAD, отслеживается на origin)

## Последний релизный тег
- v1.8.4 — fix(ui): add localization for TabView titles and fix DataService.shared reference in ContentView

## Ветка main
- bc3b7e1 chore(lint): integrate SwiftLint with custom rules for project

## Недавние коммиты (сверху вниз)
- 026a3e2 docs(changelog): добавлена запись о выравнивании стиля секций
- 663bc17 refactor(ui): унифицирован стиль секций 'Недавно прочитанное' и 'Избранное' с категориями и всеми статьями
- 75dad3d chore(ui): временный коммит — секции Недавно прочитанные и Избранное отображаются, но стиль отличается от других
- 84450bd chore(ui): временный фикс отображения, фото загружаются
- 232be86 feat(article): добавлены изображения статей и обновлен JSON
- bc3b7e1 chore(lint): integrate SwiftLint with custom rules for project
- 987695c fix(lint): correct SwiftLint config filename
- 8fb1d88 chore(lint): add SwiftLint configuration
- 2b66f1e docs: add CLEAN_CODE_CHECKLIST.md for code quality guidelines
- 982a1df v1.8.4 — fix(ui): add localization for TabView titles and fix DataService.shared reference in ContentView

## Рекомендации
- Проверять `git status` и `git branch` перед началом работы.
- Новые изменения вести в фича-ветках, потом мержить в main через PR.
- Обновлять этот файл командой:
  ```bash
  git log --oneline --decorate --graph -n 20 > Docs/git_snapshot.md
  ```
