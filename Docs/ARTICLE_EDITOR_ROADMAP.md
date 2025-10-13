# 📄 Article Editor / Mini-CMS Roadmap

## 🎯 Цель
Создать полноценный **визуальный редактор статей** внутри приложения InGermany, который со временем превратится в **мини-CMS** (content management system) и отдельное **Admin-приложение для MacOS**.  

Редактор должен позволять:
- ✍️ создавать новые статьи (title + структурированные блоки),  
- 👀 видеть Live Preview,  
- 📤 экспортировать JSON в совместимом формате,  
- 📥 импортировать JSON обратно в редактор,  
- 📚 управлять библиотекой статей.  

---

## ✅ Реализовано
- [x] **Создание статьи с блоками** (paragraph, info, warning, tip, quote, list, checklist, faq, links).  
- [x] **Редактирование блоков** (TextEditor, список, чеклист, FAQ, ссылки).  
- [x] **Удаление блоков** с подтверждением.  
- [x] **Drag & Drop сортировка** (базовая поддержка).  
- [x] **Live Preview** (ArticleRenderer).  
- [x] **Экспорт JSON** (поддержка `{ title, blocks }`).  
- [x] **Сохранение JSON в Documents/article.json**.  
- [x] **Share JSON** (через системное меню iOS).  
- [x] **Unit-тест** на экспорт (title + blocks).  

---

## 📌 Roadmap (следующие шаги)

### 🔹 Шаг 1. **Импорт JSON**
- [ ] Добавить кнопку «Импортировать JSON» в редактор.  
- [ ] Использовать `UIDocumentPickerViewController` (iOS) или `NSOpenPanel` (MacOS).  
- [ ] Загруженный JSON декодировать в `ArticleDocument` → загрузить в `ArticleEditorViewModel`.  
- [ ] Тест: импортировать ранее сохранённую статью и убедиться, что все блоки восстановлены.  

---

### 🔹 Шаг 2. **Библиотека статей (ArticleLibraryView)**
- [ ] Сохранять не один файл `article.json`, а в папку `Documents/articles/`.  
- [ ] Именовать файлы: `yyyy-MM-dd-title.json` (например, `2025-10-13-burgeramt.json`).  
- [ ] Создать экран **ArticleLibraryView** → показывает список всех JSON.  
- [ ] Возможность открыть файл в редакторе.  
- [ ] Возможность удалить файл.  

---

### 🔹 Шаг 3. **Улучшения UX**
- [ ] Drag & Drop сортировка блоков (улучшить, сделать визуально).  
- [ ] Кнопка «Duplicate block» (удвоить блок).  
- [ ] Красивые UI для `info`, `warning`, `tip` (цветные карточки с иконками).  
- [ ] Новый блок `image` (с локальной загрузкой картинок).  

---

### 🔹 Шаг 4. **Интеграция с InGermany**
- [ ] При экспорте давать опцию «Сохранить в articles проекта» (для разработчика).  
- [ ] Автоматически копировать JSON в `Services/articles/`.  
- [ ] Сделать поддержку подгрузки статей из `Documents/articles/` внутри приложения.  
- [ ] (опционально) GitHub-интеграция: редактор пушит новые статьи прямо в репозиторий.  

---

### 🔹 Шаг 5. **MacOS Admin App**
- [ ] Собрать редактор под MacOS (SwiftUI + Catalyst).  
- [ ] Поддержка drag & drop файлов из Finder.  
- [ ] Редактирование и сохранение статей прямо в папку проекта.  
- [ ] Интеграция с Git (создание коммитов и пуш прямо из админки).  

---

## 🎉 Мотивация
Каждый шаг — это маленькая победа 💪  
- Сделал экспорт → ✔️  
- Добавил импорт → ✔️  
- Открыл свою статью и отредактировал снова → ✔️  
- Получил библиотеку статей прямо в приложении → 🚀  

---

## 🤖 Инструкция для AI-агентов

### 📌 Назначение редактора
`ArticleEditorView` + `ArticleEditorViewModel` реализуют **визуальный редактор статей** в приложении InGermany.  
Редактор нужен для создания, редактирования и экспорта JSON статей, совместимых с `ArticleRenderer`.  

### 🗂 Ключевые файлы
- **Shared/Models/ArticleBlock.swift** → модель блока (paragraph, info, warning, tip, quote, list, checklist, faq, links).  
- **Shared/ViewModels/ArticleEditorViewModel.swift** → логика редактора: хранение `title`, список `blocks`, методы `addBlock`, `deleteBlock`, `moveBlock`, `exportToJSON()`, `toSections()`.  
- **Views/Editor/ArticleEditorView.swift** → UI редактора: форма с блоками, превью, кнопки Add/Export/Share.  
- **Views/Editor/BlockPickerView.swift** → выбор типа блока.  
- **Services/ArticleRenderer.swift** → эталон рендера статей из JSON.  

### 🔄 Поток работы
1. Пользователь вводит **title** и добавляет блоки в `ArticleEditorView`.  
2. Все изменения хранятся в `ArticleEditorViewModel`.  
3. Для предпросмотра используется `toSections()` → отдаёт данные в `ArticleRenderer`.  
4. Для сохранения вызывается `exportToJSON()` → создаёт `Documents/article.json` и печатает JSON в консоль.  
5. Через кнопку **Share JSON** можно сразу поделиться файлом.  

### 📤 Экспорт
Формат JSON:  
```json
{
  "title": "Пример статьи",
  "blocks": [
    { "type": "paragraph", "content": "..." },
    { "type": "info", "content": "..." },
    { "type": "list", "items": [ { "text": "..." } ] }
  ]
}

📥 Импорт (будет в будущем)

JSON можно будет загружать обратно в ArticleEditorViewModel, чтобы редактировать статьи повторно.

🛠 План расширения

Поддержка библиотеки статей (ArticleLibraryView).

Drag & drop сортировка, дублирование блоков, красивые UI-блоки.

Новый блок image.

Отдельное приложение для MacOS (Admin Panel).
