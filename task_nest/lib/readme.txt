Cubit → UseCase → Repository → DataSource → DB

Proj structure:
lib/
 ├── core/                  // common utilities
 │    ├── error/
 │    ├── logger/
 │    └── shared_prefs/
 ├── data/                  // repositories implementations, datasources, DTO
 │    ├── datasources/
 │    ├── dto_models/
 │    ├── helpers/
 │    └── repositories_impl/
 ├── domain/                // entities, abstracts, usecases
 │    ├── entities/
 │    ├── reposiroties/
 │    └── usecases/
 ├── infrastructure/        // DI, routes, localization
 │    ├── di/
 │    ├── routes/
 │    ├── localization/
 │    └── storage/
 ├── presentation/          // UI, cubits/blocs, widgets
 │    ├── bloc/
 │    ├── screens/
 │    └── widgets/
