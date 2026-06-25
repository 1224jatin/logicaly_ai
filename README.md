# logicaly_ai_project

A new Flutter project.

## Groq API setup

The AI chat and doubt scanner use Groq. Pass your key at build/run time:

```sh
flutter run --dart-define=GROQ_API_KEY=your_groq_api_key
```

For an APK that you share with testers, build it with the same define:

```sh
flutter build apk --release --dart-define=GROQ_API_KEY=your_groq_api_key
```

Do not commit API keys to source control. If a key has been shared publicly,
rotate it in the Groq console before using the app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
