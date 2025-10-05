### Unit Tests (XCTest)

- ✅ **ArticleDetailViewModelTests** — полное покрытие управления избранным, историей чтения, логики связанных статей
- ✅ **HomeViewModelTests** — проверка загрузки данных, обновления, выбора случайной статьи
- ✅ **FavoritesManagerTests** — проверка добавления/удаления избранного и фильтрации статей  
- ✅ **CategoryManagerTests** — проверка загрузки категорий, поиска по ID/имени, обновления данных
- ✅ **DataServiceTests** — проверка корректной работы с JSON (articles, categories), edge-кейсы: пустые/битые данные
- ✅ **FavoritesViewModelTests** — комплексное тестирование ViewModel избранного: состояния загрузки, переключение избранного, источник данных
- ✅ **InGermanyTests.swift** — smoke-тесты (инициализация приложения, работа FavoritesManager и DataService)

📌 **Следующие шаги (roadmap по тестам):**
- [ ] **ArticleRowViewModelTests** — тестирование управления состоянием строки статьи
- [ ] **CategoriesViewModelTests** — тестирование загрузки категорий и связанных статей
- [ ] **SearchViewModelTests** — фильтрация по тексту, тегам, категориям
- [ ] **SettingsViewModelTests** — смена языка, очистка истории, настройки
