# 🤟 Levora

> *Bridging the gap between silence and sound.*

Levora is a comprehensive communication and safety app built for the **deaf and mute community**. It combines real-time sign language detection, AI-powered sound awareness, emergency tools, and interactive learning — all in one place.

---

## 📱 Screenshots

> Add your app screenshots here

---

## ✨ Features

### 🤟 Sign Communicator
- **Sign → Text & Speech** — Real-time sign language detection using the device camera and a TFLite pose estimation model. Signs are confirmed over multiple frames for accuracy and converted to spoken text via TTS.
- **Speech → Sign** — Converts spoken words or phrases into the corresponding sign language gesture with step-by-step instructions.
- **Video Call Mode** — Live sign detection with auto-generated captions during video calls.

### 📚 Learn & Sense
- **Kids Section** — Fun animated sign cards covering Animals, Colors, Family and Feelings.
- **ISL (Indian Sign Language)** — Signs unique to India including Namaste, Chai, Rupee and more.
- **ASL (American Sign Language)** — International standard signs for everyday communication.
- **Real Life Situations** — Sign sets organized by location: Hospital, School, Home, Emergency, Market, Restaurant.
- **Stories** — Learn signs through interactive scene-by-scene stories like "Ravi goes to Hospital" and "Priya at School".
- **XP & Streak System** — Gamified learning with experience points, daily streaks and achievement badges.

### 📳 SoundSense — Sound Textures
- **Live Mic Detection** — Listens to surrounding sounds in real time using the device microphone.
- **Vibration Fingerprints** — Each sound type (Bell, Dog Bark, Siren, Breaking Glass, Rain, Fire Alarm) triggers a unique custom vibration pattern so the user can *feel* the difference.
- **Sound Library** — 10 pre-defined sound profiles with visual pattern previews. Tap any card to feel its vibration.
- **Live dB Waveform** — Real-time volume meter and waveform display showing ambient noise levels.

### 🚨 Emergency SOS
- **One-Hold SOS** — Hold the SOS button for 2 seconds to instantly send an SMS with location to the emergency contact.
- **Quick Alerts** — One-tap HELP sign, location share, and direct call to contact.
- **Bystander Bridge** — Full-screen emergency mode that displays critical information (name, blood type, allergies, medical conditions, location) for bystanders and first responders to read.
- **Status Selector** — Tap to indicate current status: Conscious / Losing Consciousness, In Pain / No Pain, Need Water / Medicine.

### 👨‍👩‍👧 Caregiver Mode
- **Room Code System** — Deaf user generates a unique room code to share with their caregiver.
- **Live Translation Feed** — Caregiver sees all detected signs in real time as a chat-style feed.
- **Two-way Communication** — Caregiver can type replies that appear on the deaf user's screen.

### 👤 Profile
- **Medical ID** — Stores name, blood type, allergies and medical conditions used in SOS.
- **Emergency Contact** — Saved contact shown in SOS and Bystander Bridge.
- **Settings** — Voice language selector (English / Tamil / Hindi), speech rate slider, vibration intensity slider, notification toggle.
- **Achievements** — 8 unlockable badges tracking learning and usage milestones.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| Navigation | GoRouter |
| Backend | Firebase (Firestore, Auth) |
| ML — Sign Detection | TFLite + Google ML Kit Pose Detection |
| Text to Speech | flutter_tts |
| Sound Detection | noise_meter |
| Haptics | vibration package |
| Fonts | Google Fonts (Poppins) |
| Local Storage | SharedPreferences |
| Camera | Flutter Camera plugin |
| Permissions | permission_handler |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code
- Android device or emulator (API 21+)
- Firebase project set up

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/levora.git
cd levora

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔑 Permissions Required

| Permission | Purpose |
|-----------|---------|
| `CAMERA` | Sign language detection |
| `RECORD_AUDIO` | Live sound detection (SoundSense) |
| `VIBRATE` | Haptic feedback patterns |
| `INTERNET` | Firebase sync |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point
├── router.dart                # GoRouter navigation
└── screens/
    ├── splash_screen.dart
    ├── home_screen.dart
    ├── communicate_screen.dart
    ├── sign_speech_screen.dart
    ├── speech_sign_screen.dart
    ├── learn_screen.dart
    ├── emergency_screen.dart
    ├── chat_video_screen.dart
    ├── profile_screen.dart
    └── sound_textures_screen.dart
```

---

## 🎯 Who Is Levora For?

- Deaf and mute individuals who need to communicate in daily life
- Parents and caregivers of deaf children
- Medical professionals and first responders
- Anyone learning Indian or American Sign Language

---

## 🗺️ Roadmap

- [ ] YAMNet TFLite model for accurate real-time sound classification
- [ ] Directional haptic compass (feel where sounds come from)
- [ ] ISL fingerspelling alphabet detector
- [ ] Multi-language support (Tamil, Hindi)
- [ ] Apple Watch haptic notifications
- [ ] Community sign dictionary

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is licensed under the MIT License.

---

## 💙 Built With Purpose

Levora was built with the belief that technology should be **accessible to everyone** — regardless of ability. Every feature was designed with the deaf and mute community at the center, not as an afterthought.

> *"Communication is a human right."*

---

Made with 💙 by the Levora Team
