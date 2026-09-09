# D&D Companion App

A Flutter-based D&D companion app focused on making it easy to browse, search, filter, and explore game rules and content.

The app currently provides a comprehensive wiki covering **Classes, Species, Spells, Feats, and Backgrounds**, with flexible ways to view and navigate content. Future updates will expand the app into a complete D&D companion with **character creation** and **DM tools**.

## Features

### D&D Wiki

Browse D&D content, including:

- **Classes**
- **Species**
- **Spells**
- **Feats**
- **Backgrounds**

Each entry can be opened and explored individually, with support for navigating through nested content.

### Flexible Content Views

Content can be viewed in multiple ways depending on user preference.

Individual sub-items can also be interacted with to change how they are opened or displayed, allowing users to customize their browsing experience.

This makes it possible to quickly switch between different ways of exploring the same information without changing the underlying content.

### Search

The wiki includes a search bar for finding content.

Search can be combined with the filtering and sorting options to find enteries quicker.

### Filters & Sorting

Wiki categories support filtering and sorting to make finding content easier.

Depending on the category, users can combine:

- Search
- Filters
- Sorting options
- Different viewing methods

This is designed to make the wiki useful both for quickly looking something up during a game and for browsing content outside of a session.

### Customizable Appearance

The app includes settings for changing the application's **color scheme**.

This allows users to personalize the appearance of the app.

## Built With

- [Flutter](https://flutter.dev/)
- Dart
- Material Design

## Requirements

Before building the project, make sure you have:

- Flutter SDK installed
- Dart SDK (included with Flutter)
- Android Studio if building for mobile
- A configured Flutter development environment

Check that Flutter is correctly installed with:

```bash
flutter doctor
```

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/dominikk-lovric/DnD-app.git
```

### 2. Install dependencies

Run:

```bash
flutter pub get
```

This downloads all dependencies defined in `pubspec.yaml`.

### 3. Check connected devices

Run:

```bash
flutter devices
```

You should see any available Android, iOS, desktop, or web devices.

### 4. Run the application

Start the app with:

```bash
flutter run
```

To target a specific device:

```bash
flutter run -d <device-id>
```

For example:

```bash
flutter run -d chrome
```

## Building the App

### Android

To create a release APK:

```bash
flutter build apk --release
```

The generated APK can be found in:

```text
build/app/outputs/flutter-apk/
```

### iOS

On macOS with Xcode installed:

```bash
flutter build ios --release
```

### Web

Build the web version with:

```bash
flutter build web --release
```

The output will be located in:

```text
build/web/
```

### Windows

To build a Windows release:

```bash
flutter build windows --release
```

### macOS

To build a macOS release:

```bash
flutter build macos --release
```

### Linux

To build a Linux release:

```bash
flutter build linux --release
```
