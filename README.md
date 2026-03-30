# Ollama Mobile Studio

A modern, production-ready mobile application for interacting with local Ollama LLMs. Built with Flutter using clean architecture and Riverpod state management.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Build](https://github.com/YOUR_USERNAME/ollama-mobile-studio/workflows/Build%20Android%20APK/badge.svg)

## Features

- 🚀 **Server Connection** - Easy setup with connection testing
- 🤖 **Model Management** - Browse, select, and pull models directly from the app
- 💬 **Chat Interface** - Modern chat UI with streaming responses
- 📝 **Markdown Support** - Rich text rendering for AI responses
- 📱 **Conversation History** - Local storage of all conversations
- 🌙 **Dark Mode** - Beautiful dark theme by default
- ⚙️ **Customizable** - Adjust temperature and context length

## Architecture

The app follows **Clean Architecture** principles with three main layers:

```
lib/
├── domain/           # Business logic layer
│   └── models/       # Core domain models
├── data/             # Data layer
│   ├── datasources/  # API services
│   ├── repositories/ # Repository implementations
│   └── storage/      # Local storage & database
└── presentation/     # UI layer
    ├── providers/    # Riverpod state management
    ├── screens/      # App screens
    ├── widgets/      # Reusable widgets
    └── theme/        # App theming
```

## Prerequisites

Before running this app, ensure you have:

1. **Flutter SDK** (version 3.0 or higher)
   ```bash
   flutter --version
   ```

2. **Ollama** installed and running on your computer
   ```bash
   # Install Ollama (macOS/Linux)
   curl -fsSL https://ollama.com/install.sh | sh
   
   # Or download from https://ollama.com for Windows
   
   # Start Ollama
   ollama serve
   ```

3. **At least one model** pulled in Ollama
   ```bash
   ollama pull llama3.2
   ```

## Installation

### 1. Clone the Project

```bash
cd ollama-mobile-studio
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (if needed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
# Run on connected device or emulator
flutter run

# Or specify platform
flutter run -d android
flutter run -d ios
```

## Configuration

### Finding Your Computer's IP Address

The mobile app needs to connect to Ollama running on your computer. Here's how to find your local IP:

**Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address" under your active network adapter (e.g., `192.168.1.100`)

**macOS:**
```bash
ipconfig getifaddr en0
# or for Ethernet:
ipconfig getifaddr en1
```

**Linux:**
```bash
hostname -I
# or
ip addr show | grep "inet "
```

### Server URL Format

Enter your server URL in the format:
```
http://YOUR_IP_ADDRESS:11434
```

Example: `http://192.168.1.100:11434`

### Firewall Configuration

**Windows:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Find Ollama and ensure both Private and Public networks are checked
4. Or add a new rule for port 11434

**macOS:**
```bash
# System Preferences > Security & Privacy > Firewall
# Add Ollama to allowed apps
```

**Linux (ufw):**
```bash
sudo ufw allow 11434/tcp
```

## Usage Guide

### 1. First Launch

1. Open the app on your mobile device
2. Enter your Ollama server URL
3. Tap "Test Connection"
4. If successful, you'll be taken to the chat screen

### 2. Selecting a Model

1. Tap the model selector in the app bar
2. Choose from available models
3. Or select "Pull New Model" to download a new one

### 3. Starting a Conversation

1. Type your message in the input field
2. Tap the send button
3. Watch the AI response stream in real-time

### 4. Managing Conversations

- Tap the history icon to view past conversations
- Swipe to delete a conversation
- Tap "New Chat" to start fresh

### 5. Settings

Access settings to:
- Change server URL
- Toggle dark/light mode
- Adjust temperature (creativity vs. focus)
- Modify context length

## Troubleshooting

### "Cannot connect to server"

1. Verify Ollama is running: `ollama list`
2. Check your IP address is correct
3. Ensure both devices are on the same network
4. Check firewall settings
5. Try restarting Ollama: `ollama serve`

### "No models available"

1. Pull a model on your computer: `ollama pull llama3.2`
2. Refresh the model list in the app
3. Ensure the model pulled successfully

### Streaming not working

1. Check network stability
2. Try a smaller model
3. Reduce context length in settings

## Project Structure

```
ollama_mobile_studio/
├── android/                # Android platform files
├── ios/                    # iOS platform files
├── lib/
│   ├── main.dart          # App entry point
│   ├── domain/            # Business logic
│   │   └── models/        # Message, Conversation models
│   ├── data/              # Data layer
│   │   ├── datasources/   # Ollama API service
│   │   ├── repositories/  # Data repositories
│   │   └── storage/       # Local storage (Hive, SharedPreferences)
│   ├── models/            # API response models
│   └── presentation/      # UI layer
│       ├── providers/     # Riverpod providers
│       ├── screens/       # App screens
│       ├── widgets/       # Reusable widgets
│       └── theme/         # App theming
├── pubspec.yaml           # Dependencies
└── README.md              # This file
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client for API calls |
| `hive` | Local database |
| `shared_preferences` | Settings storage |
| `flutter_markdown` | Markdown rendering |
| `path_provider` | File system paths |
| `uuid` | Unique ID generation |
| `intl` | Date formatting |

## API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tags` | GET | List available models |
| `/api/chat` | POST | Send chat messages (streaming) |
| `/api/pull` | POST | Download new models |
| `/api/show` | POST | Get model information |
| `/api/delete` | DELETE | Remove models |

## Building for Production

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Security Notes

⚠️ **Important Security Considerations:**

1. This app is designed for **local network use only**
2. Do not expose your Ollama server to the public internet
3. The app allows HTTP connections for local development
4. Consider using HTTPS for production deployments
5. Keep your Ollama server behind a firewall

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues:

1. Check the Troubleshooting section above
2. Ensure Ollama is running correctly
3. Verify network connectivity
4. Check firewall settings
5. Review the logs: `flutter logs`

## Acknowledgments

- [Ollama](https://ollama.com) - Local LLM runtime
- [Flutter](https://flutter.dev) - UI framework
- [Riverpod](https://riverpod.dev) - State management

---

**Happy Chatting! 🚀**
