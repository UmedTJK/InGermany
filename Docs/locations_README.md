## locations.json
Файл хранит список географических объектов для приложения **InGermany**.  
Используется как локальный fallback в `DataService` → `loadLocalLocations()`.

### Структура:
- `id`: уникальный идентификатор записи (String)
- `name`: название локации (локализуется вручную в коде, если нужно)
- `latitude`: широта
- `longitude`: долгота

### Примеры:
- Посольство Германии в Душанбе
- Ausländerbehörde Hildburghausen
- Bürgeramt Berlin
