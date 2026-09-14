/// Supported UI languages. Adding one means: add it here, add its
/// `lang/<code>.json`, and extend `AppLocalizationsSetup.supportedLocales`.
enum LanguageCode { en, ar }

/// Where the user is in the app lifecycle — drives splash routing.
enum UserCycle {
  firstOpen, // never seen onboarding
  login, // onboarded, not authenticated
  auth, // authenticated
}

/// Placeholder role model. Redefine per project.
enum UserType { guest, user, admin }

/// How [DiffImage] should interpret the path it was handed.
enum ImgPath { file, mediaPath, noKey }

/// Which empty/error illustration [ErrorText] should show.
enum MyError { search, notFound, defaultError }
