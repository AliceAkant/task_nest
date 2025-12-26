Cubit → UseCase → Repository → DataSource → БД

Структура:
lib/
 ├── core/                  // базовые утилиты, конфигурации, shared-код
 ├── data/                  // реализации репозиториев, datasources, DTO
 │    ├── datasources/
 │    ├── dto_models/
 │    ├── helpers/
 │    └── repositories_impl/
 ├── domain/                // сущности, абстракции, usecases
 │    ├── entities/
 │    ├── reposiroties/
 │    └── usecases/
 ├── infrastructure/        // всё, что касается DI, роутинга, локализации, темы
 │    ├── di/
 │    ├── routes/
 │    ├── localization/
 │    └── storage/
 ├── presentation/          // UI, cubits/blocs, виджеты
 │    ├── bloc/
 │    ├── screens/
 │    └── widgets/

Связь DI:

DataSource (data) - слой реализации сбора данных (апи, бд)

Repository (domain) - контракт, описывающий возможные методы

RepositoryImpl (data) - реализует Repository и преобразовывает типы из DTO в entities