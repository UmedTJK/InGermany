📄 Article Editor / Mini-CMS Roadmap

## 🎯 Цель
Создать полноценный **визуальный редактор статей** для приложения InGermany, который со временем превратится в **мини-CMS** (content management system) и отдельное **Admin-приложение для MacOS**.  

Редактор должен позволять:
- ✍️ создавать новые статьи (title + структурированные блоки),  
- 👀 видеть Live Preview,  
- 📤 экспортировать JSON в совместимом формате,  
- 📥 импортировать JSON обратно в редактор,  
- 📚 управлять библиотекой статей.  

## 🏗️ ТЕКУЩАЯ АРХИТЕКТУРА (ОБНОВЛЕНО 18.10.2025)

### 📦 Модульная структура проекта
```
InGermany/
├── InGermany.xcodeproj/                 # Основное iOS приложение
├── InGermanyCMS/                        # Отдельное macOS CMS приложение
│   └── Views/                           # Views CMS приложения
│       ├── ArticleLibraryView.swift
│       ├── DemoArticleView.swift
│       ├── ArticleEditorView.swift      # ✅ ОБНОВЛЕНО: Split-view с Live Preview
│       ├── BlockPickerView.swift
│       └── BlockEditor.swift
└── Packages/                            # Swift Packages
    ├── ArticleKit/                      # Основной пакет редактора
    │   ├── Sources/ArticleKit/
    │   │   ├── Models/                  # Модели данных
    │   │   │   ├── ArticleBlock.swift   # ✅ ОБНОВЛЕНО: Equatable conformance
    │   │   │   ├── ArticleDocument.swift
    │   │   │   ├── ArticleSectionDTO.swift
    │   │   │   └── BlockType.swift
    │   │   ├── ViewModels/              # Бизнес-логика
    │   │   │   ├── ArticleEditorViewModel.swift # ✅ ОБНОВЛЕНО: Live Preview tracking
    │   │   │   └── ArticleLibraryViewModel.swift
    │   │   └── Renderer/                # Рендеринг статей
    │   │       └── ArticleRenderer.swift
    │   └── Package.swift
    └── SharedKit/                       # Общие компоненты
        └── Sources/SharedKit/
            ├── Services/
            │   └── LocalizationManager.swift
            └── UI/
                └── LoadingView.swift
```

### 🔄 Поток данных с Live Preview
```
ArticleLibraryView (InGermanyCMS)
    ↓
ArticleLibraryViewModel (ArticleKit) 
    ↓  
FileManager (Documents/) ←→ ArticleDocument
    ↓
ArticleEditorView (Split-view) ←→ ArticleEditorViewModel 
    ↓  
┌─ Editor Panel ────────────────────┐
│ BlockListView → BlockEditor       │
│ (левая панель)   (правая панель)  │
└───────────────────────────────────┘
    ↓ (real-time sync)
┌─ Preview Panel ───────────────────┐
│ ArticleRenderer ← ArticleSectionDTO│
│   (Live Preview)                  │
└───────────────────────────────────┘
```

## 📊 СТАТУС РЕАЛИЗАЦИИ (ОБНОВЛЕНО 25.10.2025)

### ✅ **ВЫПОЛНЕНО - ОСНОВНАЯ ФУНКЦИОНАЛЬНОСТЬ**

#### 🔹 Модульная архитектура
- [x] **ArticleKit** - полный пакет для работы со статьями
- [x] **SharedKit** - общие сервисы и UI компоненты
- [x] **Настроены зависимости** между пакетами и приложениями

#### 🔹 Кросс-платформенная поддержка
- [x] **Единый код** для iOS и macOS
- [x] **ArticleKit** работает в обоих приложениях
- [x] **InGermanyCMS** - отдельное macOS приложение

#### 🔹 Библиотека статей
- [x] **ArticleLibraryView** - библиотека статей с файловой системой
- [x] **Создание статей** - генерация новых ArticleDocument
- [x] **Управление статьями** - удаление, обновление метаданных
- [x] **Empty states** - красивые состояния при отсутствии статей
- [x] **Навигация** между библиотекой и редактором

#### 🔹 Визуальный редактор
- [x] **ArticleEditorView** - основной интерфейс редактора
- [x] **BlockPickerView** - выбор типов блоков с иконками
- [x] **BlockEditor** - редакторы для разных типов блоков
- [x] **Панель инструментов** - управление блоками
- [x] **Список блоков** - отображение добавленных блоков

#### 🔹 🎉 LIVE PREVIEW SYSTEM (НОВОЕ!)
- [x] **Split-view интерфейс** - редактор слева, превью справа
- [x] **Real-time синхронизация** - изменения сразу видны в превью
- [x] **Переключение режимов** - показать/скрыть превью
- [x] **Индикатор состояния** - визуализация несохраненных изменений
- [x] **Авто-отслеживание** - автоматическое определение изменений

#### 🔹 Рендеринг статей
- [x] **ArticleRenderer** - полная поддержка всех типов блоков
- [x] **DemoArticleView** - работающее демо с программными данными
- [x] **Совместимость форматов** - единый ArticleSectionDTO
- [x] **Устойчивость к ошибкам** - обработка некорректных данных

### 🚧 **В РАЗРАБОТКЕ**

#### 🔹 ArticleEditorView улучшения
- [ ] **Drag & Drop** сортировка блоков
- [ ] **Автосохранение** с интеллектуальной задержкой
- [ ] **Undo/Redo** поддержка действий

#### 🔹 Управление блоками
- [ ] **Расширенные редакторы** для всех типов блоков
- [ ] **Валидация данных** в реальном времени
- [ ] **Горячие клавиши** для быстрого доступа

### 📋 **ПЛАНИРУЕТСЯ**

#### 🔹 Расширение функциональности
- [ ] **Экспорт/Импорт JSON** с файловым диалогом
- [ ] **Поиск и фильтрация** в библиотеке статей
- [ ] **Шаблоны статей** для быстрого старта
- [ ] **Темная тема** поддержка

#### 🔹 Git интеграция
- [ ] **GitPublisher** сервис для автоматических коммитов
- [ ] **Publish функциональность** - push в удаленный репозиторий
- [ ] **Статус синхронизации** в UI

---

## 🎯 БЛИЖАЙШИЕ ЗАДАЧИ

### 1. **Drag & Drop сортировка** (ВЫСОКИЙ ПРИОРИТЕТ)
- Перетаскивание блоков в списке
- Визуальные индикаторы при перемещении
- Сохранение нового порядка блоков

### 2. **Автосохранение с задержкой** (ВЫСОКИЙ ПРИОРИТЕТ)
- Интеллектуальное автосохранение после паузы в редактировании
- Визуальная индикация процесса сохранения
- Защита от потери данных

### 3. **Улучшение редакторов блоков** (СРЕДНИЙ ПРИОРИТЕТ)
- Полнофункциональный редактор изображений
- Редактор ссылок с валидацией URL
- Расширенный редактор для FAQ блоков

### 4. **Горячие клавиши** (СРЕДНИЙ ПРИОРИТЕТ)
- Быстрые клавиши для добавления блоков
- Навигация по интерфейсу с клавиатуры
- macOS-оптимизированные шорткаты

---

## 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ РЕАЛИЗАЦИИ

### 📁 Формат хранения статей
```swift
public struct ArticleDocument: Codable, Identifiable, Hashable {
    public let id = UUID()
    public var title: String
    public var sections: [ArticleSectionDTO]
    public let url: URL?
}
```

### 🔄 Преобразование моделей
```swift
// ArticleBlock (редактор) ↔ ArticleSectionDTO (рендерер)
ArticleBlock.fromSection(_:)    // DTO → Editor model
ArticleBlock.toSectionDTO()     // Editor model → DTO
```

### 🎨 Поддерживаемые типы блоков
```swift
public enum BlockType: String, CaseIterable {
    case paragraph, info, warning, tip, quote
    case checklist, faq, list, links, image
}
```

### 🎯 Реализованные UI компоненты
- `BlockRowView` - строка блока с иконкой и предпросмотром
- `BlockEditor` - универсальный редактор для всех типов блоков
- `ArticleLibraryView` - улучшенная библиотека с empty states
- `ArticleEditorView` - **split-view с Live Preview**

### 🔥 Live Preview Architecture
```swift
// Real-time synchronization
ArticleEditorView {
    HSplitView {
        EditorPanel()       // Left - Editing
        PreviewPanel()      // Right - Live Preview
    }
}

// Change tracking in ViewModel
@Published var blocks: [ArticleBlock]
@Published var hasUnsavedChanges: Bool
private var originalBlocks: [ArticleBlock] // For comparison
```

---

## 🚀 ИНСТРУКЦИЯ ДЛЯ ПРОДОЛЖЕНИЯ РАЗРАБОТКИ

### 📌 Текущий фокус
**Улучшение UX редактора через Drag & Drop и автосохранение** с последующей интеграцией расширенной функциональности.

### 🔄 Рабочий процесс
1. **ArticleLibraryView** → выбор/создание статьи
2. **ArticleEditorView** → редактирование контента через BlockEditor
3. **Live Preview** → мгновенный просмотр изменений в реальном времени ✅
4. **BlockPicker** → добавление новых типов блоков
5. **Save/Autosave** → сохранение в JSON файлы

### 🛠 Технический стек
- **SwiftUI** + **Combine** для реактивного UI
- **FileManager** для локального хранения
- **Swift Package Manager** для модульности
- **@StateObject/@Binding** для управления состоянием
- **HSplitView** для профессионального интерфейса

### 🎯 КРИТЕРИИ УСПЕХА (ОБНОВЛЕНО)
- [x] Статьи создаются и удаляются в библиотеке
- [x] Блоки добавляются и редактируются в визуальном редакторе
- [x] Разные типы блоков поддерживаются с соответствующими редакторами
- [x] Demo Article работает без ошибок
- [x] **Live Preview показывает актуальный результат в реальном времени** ✅
- [ ] Drag & Drop сортировка блоков работает
- [ ] Автосохранение защищает от потери данных
- [ ] Изменения сохраняются автоматически

---

## 💡 ПРИМЕЧАНИЯ ДЛЯ РАЗРАБОТЧИКОВ

### Архитектурные решения
- **Модульность**: ArticleKit изолирует логику редактора
- **Кросс-платформенность**: Единый код для iOS/macOS  
- **Тестируемость**: ViewModels независимы от UI
- **Расширяемость**: Легко добавлять новые типы блоков
- **Реактивность**: Combine для real-time обновлений

### Успешные улучшения
1. **Устойчивый ArticleRenderer** - обрабатывает ошибки данных
2. **Программное создание демо-статьи** - обход проблем с JSON
3. **Улучшенные empty states** - лучший UX при отсутствии данных
4. **Иконки и цвета** - визуальное различие типов блоков
5. **🎉 Live Preview System** - профессиональный split-view интерфейс ✅

### Следующие технические шаги
1. Реализовать Drag & Drop для сортировки блоков
2. Внедрить интеллектуальное автосохранение
3. Добавить расширенные редакторы для изображений и ссылок
4. Реализовать горячие клавиши для macOS

### Метрики прогресса
- ✅ Модульная архитектура реализована
- ✅ Библиотека статей работает с улучшенным UX
- ✅ Визуальный редактор базово функционирует
- ✅ **Live Preview реализован и работает** ✅
- 🔄 Drag & Drop в разработке
- ◻️ Автосохранение в планах
- ◻️ Git интеграция в планах

**Текущий статус 18.10.2025**: Проект значительно улучшен, реализована ключевая функция Live Preview. Редактор теперь имеет профессиональный интерфейс с real-time предпросмотром. Готов к реализации Drag & Drop и автосохранения.
```


Вот что можно реализовать **очень быстро** (за 1-2 часа):

## 🚀 МГНОВЕННЫЕ УЛУЧШЕНИЯ

### 1. **Автосохранение с таймером** ⏰ (15 минут)
```swift
// В ArticleEditorViewModel
private var autosaveTimer: Timer?

private func setupAutosave() {
    autosaveTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
        if self.hasUnsavedChanges {
            self.saveDocument()
        }
    }
}
```

### 2. **Улучшенные иконки состояний** 🎨 (10 минут)
```swift
// В editorToolbar - заменить простой текст на красивые индикаторы
if viewModel.isSaving {
    HStack {
        ProgressView()
            .scaleEffect(0.8)
        Text("Сохранение...")
    }
    .foregroundColor(.blue)
} else if viewModel.hasUnsavedChanges {
    HStack {
        Image(systemName: "circle.fill")
            .foregroundColor(.orange)
            .font(.system(size: 8))
        Text("Не сохранено")
    }
    .foregroundColor(.orange)
} else {
    HStack {
        Image(systemName: "checkmark.circle.fill")
        Text("Сохранено")
    }
    .foregroundColor(.green)
}
```

### 3. **Быстрые клавиши для BlockPicker** ⌨️ (20 минут)
```swift
// В ArticleEditorView
.onCommand(#selector(NSStandardKeyBindingResponding.insertNewline(_:))) {
    viewModel.showBlockPicker = true
}
.keyboardShortcut("n", modifiers: [.command, .shift])
```

### 4. **Preview заголовок с редактированием** 📝 (15 минут)
```swift
// В previewContent - сделать заголовок редактируемым
TextField("Заголовок статьи", text: $viewModel.documentTitle)
    .font(.largeTitle)
    .fontWeight(.bold)
    .textFieldStyle(.plain)
```

### 5. **Счетчик блоков** 🔢 (5 минут)
```swift
// В blocksListView под заголовком
Text("Блоки статьи")
    .font(.headline)
Text("\(viewModel.blocks.count) блоков")
    .font(.caption)
    .foregroundColor(.secondary)
```

### 6. **Быстрый предпросмотр типа блока** 👁️ (10 минут)
```swift
// В BlockRowView - добавить предпросмотр при наведении
.contentShape(Rectangle())
.onHover { hovering in
    if hovering {
        // Показать quick preview
    }
}
```

### 7. **Улучшенный Empty State** 🎯 (15 минут)
```swift
// В emptyBlocksView - добавить действие
Button("Добавить первый блок") {
    viewModel.showBlockPicker = true
}
.buttonStyle(.borderedProminent)
```

### 8. **Быстрое переименование статьи** ✏️ (10 минут)
```swift
// В navigationTitle сделать редактируемым
.navigationTitle(document.title)
.toolbar {
    Button("Редактировать заголовок") {
        // Показать диалог редактирования
    }
}
```

### 9. **Статус бар с информацией** 📊 (10 минут)
```swift
// Внизу ArticleEditorView
VStack(spacing: 0) {
    // основной контент...
    
    // Status Bar
    HStack {
        Text("Блоков: \(viewModel.blocks.count)")
        Spacer()
        Text(document.url?.lastPathComponent ?? "Новый документ")
    }
    .font(.caption)
    .foregroundColor(.secondary)
    .padding(8)
    .background(Color(NSColor.controlBackgroundColor))
}
```

### 10. **Кнопка дублирования блока** 📋 (15 минут)
```swift
// В BlockRowView contextMenu
Button("Дублировать") {
    viewModel.duplicateBlock(block)
}

// В ArticleEditorViewModel
public func duplicateBlock(_ block: ArticleBlock) {
    let duplicatedBlock = ArticleBlock(
        type: block.type,
        content: block.content,
        items: block.items
    )
    blocks.append(duplicatedBlock)
    markAsModified()
}
```

## 🎯 САМЫЕ БЫСТРЫЕ И ЗАМЕТНЫЕ УЛУЧШЕНИЯ:

**Топ-3 для быстрого результата:**
1. **Автосохранение** (15 мин) - сразу решает проблему потери данных
2. **Улучшенные индикаторы** (10 мин) - сразу улучшает UX  
3. **Счетчик блоков** (5 мин) - простая но полезная информация

## 🚀 КОМБИНАЦИЯ БЫСТРЫХ ФИЧ:

Можно сделать **"быстрый пакет улучшений"** за 1 час:

```swift
// 1. Автосохранение + 2. Красивые индикаторы + 3. Счетчик блоков
// = Профессиональный вид за 30 минут!
