# Quick Start Guide

## Running the App

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters (if needed)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run on Device
```bash
flutter run
```

## Connecting to Ollama

### On Your Computer:
1. **Start Ollama:**
   ```bash
   ollama serve
   ```

2. **Find Your IP:**
   - Windows: `ipconfig`
   - Mac/Linux: `hostname -I` or `ipconfig getifaddr en0`

3. **Pull a Model (if you haven't):**
   ```bash
   ollama pull llama3.2
   ```

4. **Configure Firewall:**
   - Allow port 11434 for incoming connections

### On Your Phone:
1. Open the app
2. Enter: `http://YOUR_IP:11434` (e.g., `http://192.168.1.100:11434`)
3. Tap "Test Connection"
4. Start chatting!

## Common Issues

| Issue | Solution |
|-------|----------|
| Connection timeout | Check firewall, ensure same WiFi network |
| No models shown | Run `ollama pull llama3.2` on computer |
| Streaming fails | Check network stability |

## Project Structure
```
lib/
├── main.dart                          # App entry point
├── domain/models/                     # Core models
│   ├── message.dart                   # Chat message model
│   └── conversation.dart              # Conversation model
├── data/
│   ├── datasources/ollama_api_service.dart  # API calls
│   ├── repositories/                  # Data repositories
│   └── storage/                       # Local storage
└── presentation/
    ├── providers/                     # Riverpod state
    ├── screens/                       # UI screens
    ├── widgets/                       # Reusable widgets
    └── theme/app_theme.dart           # App theming
```

## Key Features

✅ Server connection with testing  
✅ Model browsing and pulling  
✅ Streaming chat responses  
✅ Markdown rendering  
✅ Conversation history (local DB)  
✅ Dark/Light theme  
✅ Temperature & context settings  
✅ Copy to clipboard  
✅ Swipe to delete conversations  

## API Endpoints Used

- `GET /api/tags` - List models
- `POST /api/chat` - Chat with streaming
- `POST /api/pull` - Download models

---

For detailed documentation, see [README.md](README.md)
