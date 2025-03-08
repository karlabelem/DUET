# Contributing to DUET

Thank you for your interest in contributing to DUET! This document provides guidelines and instructions for contributing to the project.

## Obtaining the Source Code

1. Clone the main repository:

```bash
git clone https://github.com/your-repo/duet.git
cd duet
```

## Directory Structure

```bash
DUET/
├── Status Reports/ # Weekly project status reports
├── proposal/ # Original project proposal and feedback
├── duet_application/ # Main Flutter application source code
│ ├── lib/ # Core application code, in /src/
│ ├── test/ # Test files
│ ├── assets/ # Images, fonts, and other static files
│ ├── android/ # Android-specific configurations
│ ├── ios/ # iOS-specific configurations
│ └── web/ # Web platform configurations
```


## Building the Software

### Prerequisites

1. Install Flutter by following the official guide: [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Install Android Studio or Visual Studio Code with Flutter extensions
3. Set up Firebase:

```bash

# Install Firebase CLI

dart pub global activate flutterfire_cli

# Add to your shell configuration
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# Configure Firebase
flutterfire configure


# Install required gem for Xcode setup

sudo gem install xcodeproj
```

### Building the Application

1. Navigate to the application directory:

```bash
cd duet_application
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the Application

```bash
flutter run
```

## Testing

### Running Tests

1. Navigate to the application directory:

```bash
cd duet_application
```

2. Run all tests:

```bash
flutter test
```

## Building a Release

1. Update version numbers:
   - In `pubspec.yaml`
   - In Android's `build.gradle`
   - In iOS's `Info.plist`

2. Create a release build:

For Android:
```bash
flutter build apk --release
```

For iOS:
```bash
flutter build ios --release
```

For Web:
```bash
flutter build web --release
```

3. Tag the release:
```bash
git tag -a v1.x.x -m "Release version 1.x.x"
git push origin v1.x.x
```

## Continuous Integration

We use GitHub Actions for CI/CD. All pull requests must pass:
- Unit tests
- Build checks
- Code formatting checks

The CI workflow is defined in:
```yaml:.github/workflows/unit_tests.yaml
startLine: 1
endLine: 31
```

## Code Style Guidelines

We follow the official Dart style guide: [Effective Dart](https://dart.dev/effective-dart/style)

Key points:
- Use `dart format` to ensure consistent formatting
- Run `dart analyze` before committing to check for issues
- Follow Flutter's widget testing best practices
- Document all public APIs

## Questions or Issues?

Feel free to open an issue on GitHub or reach out through our Discord channel for any questions or concerns.

