# splish splash

a flutter based photo browsing app (weird to name it splish splash but yes)

## features
- firebase email/password authentication (stays signed in)
- staggered photo feed with infinite scroll and pull to refresh
- search with loading, empty and error states
- photo detail screen with save and share, transition and haptics
- per account saved photos that persist and sync across screens
- light/ dark/ system theme, remembered between launches

## tech
flutter, provider (state management), named routes, firebase auth,
shared_preferences, pixabay API.

## setup
1. `flutter pub get`
2. copy `lib/secrets.example.dart` to `lib/secrets.dart` and paste your
   Pixabay API key (https://pixabay.com/api/docs/).
3. `flutter run` (android emulator or device)

firebase is already configured in `lib/firebase_options.dart`.

## credits
photos provided by pixabay (pexels wasn't issuing any new APIs) 
