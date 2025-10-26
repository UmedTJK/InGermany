import SwiftUI
import ArticleKit

public struct DemoArticleView: View {
    @State private var sections: [ArticleSectionDTO] = []
    @State private var loadError: String?
    @State private var isLoading: Bool = true

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Загрузка демо-статьи...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let loadError = loadError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ошибка загрузки JSON:")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(loadError)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if !sections.isEmpty {
                    ArticleRenderer(sections: sections)
                } else {
                    Text("Нет данных для отображения")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("🎨 Демо: Все возможности редактора")
        }
        .onAppear {
            loadDemoArticle()
        }
    }

    private func loadDemoArticle() {
        isLoading = true
        loadError = nil
        
        print("🔍 Создаем расширенную демо-статью...")
        createRichDemoArticle()
    }
    
    private func createRichDemoArticle() {
        // Создаем БОГАТУЮ демо-статью со ВСЕМИ типами блоков
        sections = [
            // Заголовок и введение
            ArticleSectionDTO(
                type: "paragraph",
                content: "# 🎯 Демонстрация всех возможностей редактора\n\nЭтот документ показывает ВСЕ типы контента, которые можно создавать в InGermanyCMS редакторе."
            ),
            
            // Текстовые блоки разных типов
            ArticleSectionDTO(
                type: "paragraph",
                content: "## 📝 Текстовые блоки\n\nОбычный параграф для основного текста. Здесь можно писать длинные тексты, объяснения, описания и любую текстовую информацию."
            ),
            
            ArticleSectionDTO(
                type: "info",
                content: "💡 **Информационный блок**\n\nИспользуется для важной информации, подсказок или полезных фактов. Отлично подходит для выделения ключевых моментов."
            ),
            
            ArticleSectionDTO(
                type: "warning",
                content: "⚠️ **Предупреждающий блок**\n\nВажные предупреждения, ограничения или то, на что нужно обратить особое внимание. Идеально для юридической информации или требований."
            ),
            
            ArticleSectionDTO(
                type: "tip",
                content: "🎯 **Блок с советом**\n\nПрактические советы, лайфхаки и рекомендации. Помогает пользователям быстрее достичь желаемого результата."
            ),
            
            ArticleSectionDTO(
                type: "quote",
                content: "«Редактор должен быть как хороший слуга — незаметный, но всегда готовый помочь.»\n\n— Анонимный разработчик"
            ),
            
            // Списки и структуры
            ArticleSectionDTO(
                type: "paragraph",
                content: "## 📋 Списки и структуры"
            ),
            
            ArticleSectionDTO(
                type: "checklist",
                items: [
                    ArticleItemDTO(text: "Создать аккаунт в банке", isCompleted: true),
                    ArticleItemDTO(text: "Зарегистрироваться по месту жительства", isCompleted: true),
                    ArticleItemDTO(text: "Найти работу по специальности", isCompleted: false),
                    ArticleItemDTO(text: "Выучить немецкий до уровня B2", isCompleted: false),
                    ArticleItemDTO(text: "Получить вид на жительство", isCompleted: true)
                ]
            ),
            
            ArticleSectionDTO(
                type: "list",
                items: [
                    ArticleItemDTO(text: "Паспорт или удостоверение личности"),
                    ArticleItemDTO(text: "Подтверждение адреса проживания"),
                    ArticleItemDTO(text: "Фотография на паспорт"),
                    ArticleItemDTO(text: "Подтверждение финансовой состоятельности")
                ]
            ),
            
            // FAQ секция
            ArticleSectionDTO(
                type: "paragraph",
                content: "## ❓ Часто задаваемые вопросы"
            ),
            
            ArticleSectionDTO(
                type: "faq",
                content: "Как долго обрабатывается виза?",
                items: [
                    ArticleItemDTO(text: "Стандартный срок обработки визы составляет от 2 до 8 недель, в зависимости от типа визы и загруженности консульства.")
                ]
            ),
            
            ArticleSectionDTO(
                type: "faq",
                content: "Нужно ли знать немецкий для переезда?",
                items: [
                    ArticleItemDTO(text: "Для некоторых типов виз знание немецкого обязательно, для других — рекомендуется. В IT-сфере часто достаточно английского, но для бытовой жизни немецкий очень пригодится.")
                ]
            ),
            
            ArticleSectionDTO(
                type: "faq",
                content: "Какая средняя зарплата в Германии?",
                items: [
                    ArticleItemDTO(text: "Средняя зарплата варьируется от €45,000 до €85,000 в год в зависимости от специализации, опыта и региона.")
                ]
            ),
            
            // Блок с ссылками (используем обычный список с форматированием)
            ArticleSectionDTO(
                type: "paragraph",
                content: "## 🔗 Полезные ресурсы\n\nВ редакторе вы можете создавать блоки ссылок с валидацией URL и автоматическим определением домена."
            ),
            
            ArticleSectionDTO(
                type: "list",
                items: [
                    ArticleItemDTO(text: "🌐 Официальный портал Германии - germany.info"),
                    ArticleItemDTO(text: "🏛️ Федеральное ведомство по миграции - bamf.de"),
                    ArticleItemDTO(text: "💼 Работа в Германии для IT-специалистов - make-it-in-germany.com"),
                    ArticleItemDTO(text: "🏠 Поиск жилья - immobilienscout24.de")
                ]
            ),
            
            // Изображения
            ArticleSectionDTO(
                type: "paragraph",
                content: "## 🖼️ Блоки с изображениями"
            ),
            
            ArticleSectionDTO(
                type: "paragraph",
                content: "В редакторе можно добавлять изображения с подписями и альтернативным текстом для доступности."
            ),
            
            ArticleSectionDTO(
                type: "image",
                content: "Пример изображения",
                imageData: ImageData(
                    imagePath: "germany6.jpg", // если добавить в Assets.xcassets
                    caption: "Замок Нойшванштайн в Баварии - одно из самых фотографируемых мест Германии",
                    altText: "Замок Нойшванштайн на фоне гор"
                )
            ),
            
            // Комбинированный пример
            ArticleSectionDTO(
                type: "paragraph",
                content: "## 🎭 Комбинированный пример"
            ),
            
            ArticleSectionDTO(
                type: "info",
                content: "**Процесс переезда в Германию:**"
            ),
            
            ArticleSectionDTO(
                type: "checklist",
                items: [
                    ArticleItemDTO(text: "Подготовить документы", isCompleted: true),
                    ArticleItemDTO(text: "Подать заявление на визу", isCompleted: true),
                    ArticleItemDTO(text: "Найти временное жилье", isCompleted: false),
                    ArticleItemDTO(text: "Зарегистрироваться в ведомстве", isCompleted: false),
                    ArticleItemDTO(text: "Открыть банковский счет", isCompleted: false)
                ]
            ),
            
            ArticleSectionDTO(
                type: "tip",
                content: "💫 **Совет**: Начните учить немецкий заранее, это значительно упростит адаптацию."
            ),
            
            // Заключение
            ArticleSectionDTO(
                type: "paragraph",
                content: "## 🎉 Заключение\n\nЭтот демо-документ показывает **все возможности** вашего редактора статей. Вы можете создавать:\n\n- 📝 Разнообразные текстовые блоки\n- ✅ Интерактивные чек-листы\n- 📋 Структурированные списки\n- ❓ FAQ секции\n- 🔗 Ссылки на ресурсы\n- 🖼️ Изображения с подписями\n- 💡 Информационные блоки\n- ⚠️ Предупреждения\n- 🎯 Советы\n- 💬 Цитаты\n\n**Редактор готов к созданию профессионального контента!**"
            ),
            
            ArticleSectionDTO(
                type: "warning",
                content: "⚠️ **Важно**: Всегда проверяйте актуальность информации на официальных сайтах, так как миграционное законодательство может меняться."
            ),
            
            ArticleSectionDTO(
                type: "info",
                content: "🚀 **Готовы начать?** Создайте свою первую статью в библиотеке статей и опробуйте все возможности редактора!"
            )
        ]
        
        isLoading = false
        print("✅ Богатая демо-статья создана: \(sections.count) секций, включая ВСЕ типы блоков")
    }
}
