# ssme

Team base architecture boilerplate. Clean Architecture + Cubit + GetIt + Dio + go_router, with JSON-file i18n and a light/dark design-token theme.

## Getting started

```bash
cp .env.example .env      # then fill in BASE_URL
flutter pub get
flutter run
```

Rename the package for a new project:

```bash
dart pub global activate rename
rename setAppName --targets ios,android --value "My App"
rename setBundleId --targets ios,android --value com.mycompany.myapp
# then find/replace `package:ssm/` and `name: ssm` in pubspec.yaml
```

## Layers

```
lib/
├── main.dart                  env -> DI -> chrome -> runApp
├── app.dart                   MaterialApp.router, ScreenUtil, theme + locale providers
├── injection_container.dart   composition root (GetIt) + global accessors
│
├── config/
│   ├── env/       AppEnv — typed access to .env
│   ├── locale/    JSON localization delegate + `'key'.tr`
│   ├── routes/    AppRoutes (go_router) + navigator observer
│   └── themes/    lightTheme / darkTheme + ThemeCubit
│
├── core/                      no feature may be imported from here
│   ├── api/          DioConsumer, interceptors, AuthEventBus, status codes, endpoints
│   ├── base_classes/ BaseOneResponse, BaseListResponse, Pagination, APIError
│   ├── error/        AppException -> Failure
│   ├── usecases/     UseCase<Type, Params>, NoParams
│   ├── services/     bloc observer, shared prefs, secure storage
│   ├── utils/        extensions, validators, design tokens (colors, text styles)
│   └── widgets/      shared UI kit
│
└── features/
    ├── splash/       boot screen
    ├── home/         placeholder + the cubit/injection templates to copy
    └── language/     worked example of the full stack
```

Data flow, one direction only:

```
Screen -> Cubit -> UseCase -> Repository (abstract)
                                   |
                          RepositoryImpl -> DataSource -> DioConsumer
```

The repository catches `AppException` and returns `Either<Failure, T>`; the cubit folds that into a state. Nothing above the repository ever sees an exception.

## Adding a feature

1. Create `lib/features/<name>/` with `data/{datasources,models,repositories}`, `domain/{entities,repositories,usecases}`, `presentation/{cubit,pages,widgets}`.
2. Copy `features/home/presentation/cubit/` for the cubit/state shape and `features/home/home_injection.dart` for the registrations.
3. Add endpoints to `core/api/api_endpoints.dart` — paths only, never full URLs.
4. Call `init<Name>FeatureInjection()` from `ServiceLocator.init()` in `injection_container.dart`.
5. Add a path, a name and a `GoRoute` to `config/routes/app_routes.dart`.

Registration convention: cubits are `registerFactory`; use cases, repositories and data sources are `registerLazySingleton`.

## Configuration

`.env` drives the base URL, timeouts and network logging. It is **bundled as a Flutter asset**, so anyone who unzips the APK/IPA can read it — put base URLs and feature flags there, never a private key. For per-environment values:

```bash
flutter run --dart-define=ENV_FILE=.env.production
```

Declare each extra file under `flutter: assets:` in `pubspec.yaml`. `.env.production`, `.env.staging` and `.env.local` are gitignored.

## Theming

All colours live in `Palette` (`core/utils/values/app_colors.dart`) — change those values and the whole app follows. `AppColors` exposes them as a `ThemeExtension` so light and dark resolve automatically.

In widgets use `context.colors.primary`. Outside a widget, the global `colors` getter works — it is re-registered from `MaterialApp.builder` on every theme change.

Typography is in `core/utils/values/text_styles.dart` (`TextStyles.semiBold18()`). To brand: drop font files into `assets/fonts/`, uncomment the `fonts:` block in `pubspec.yaml`, and set `Fonts.primary`.

Sizes use `flutter_screenutil` (`.w .h .sp .r`) relative to `kDesignSize` in `app.dart` — set that to your Figma frame.

## Localization

Translations are plain JSON in `lang/`. To add a key: add it to **both** `lang/en.json` and `lang/ar.json`, then add a getter to `core/utils/values/strings.dart`. A missing key renders `"<key> not found"`.

To add a language: add its enum value to `LanguageCode`, create `lang/<code>.json`, and add the `Locale` to `AppLocalizationsSetup.supportedLocales`. The change-language screen enumerates `LanguageCode.values`, so it picks the new one up automatically.

## Networking

`DioConsumer` is the only thing that talks to Dio. It attaches the Bearer token from secure storage before every request and maps failures to typed exceptions:

| Condition | Exception | Failure |
|---|---|---|
| 401 / 403 | `UnauthorizedException` | `UnauthorizedFailure` |
| 422 | `ServerException` (first validation message) | `ServerFailure` |
| timeout / no connection | `InternetConnectionException` | `NetworkFailure` |
| anything else | `ServerException` | `ServerFailure` |

A 401 also fires `AuthEventBus.unauthorizedStream`, which `app.dart` listens to for a global sign-out. Point that listener at your login route once you have auth.

## Testing

```bash
flutter test
flutter analyze
dart format lib/
```
