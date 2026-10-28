# kmusic (iOS Music Player for iPhone 15 Pro Max)

A native iOS music player written in SwiftUI inspired by Apple Music's design and architecture.

---

## 1. How Apple Music Works

Apple Music consists of three major layers:

1. **Client Interface & Audio Engine (iOS / macOS)**:
   - Built natively using SwiftUI and UIKit.
   - Powered by `AVFoundation` (`AVPlayer`, `AVAudioSession`, and `AVAudioEngine`) for audio rendering and spatial audio / Dolby Atmos decoding.
   - Integrated with iOS System Controls: `MPRemoteCommandCenter` (lock screen controls, dynamic island, control center) and `MPNowPlayingInfoCenter`.

2. **Content Protection & Delivery**:
   - **FairPlay DRM**: Apple's proprietary Digital Rights Management system that secures audio streams via encrypted HLS (`m3u8`) segments and hardware key decryption.
   - **Apple Music API / MusicKit**: The official, legal SDK provided by Apple for developers to search catalogs, fetch user playlists, and trigger playback within third-party apps with user consent.

3. **Backend Cloud Architecture**:
   - Distributed CDNs, search indices, metadata catalogs, and recommendation algorithms.

> **Note on Reverse Engineering & DRM**:
> Proprietary streaming infrastructure and DRM decryption (FairPlay) cannot be cloned or bypassed with REA (Reverse Engineer Anything), as DRM circumvention and piracy harvesting are strictly prohibited and technically enforced at the hardware/Secure Enclave level. Official access requires Apple's **MusicKit for Swift**.

---

## 2. Project Architecture (`kmusic`)

This project implements an Apple Music-style music player:

- **`kmusicApp.swift`**: App entry point configuring the shared audio environment.
- **`AudioPlayerService.swift`**: Core audio player service using `AVFoundation`, background audio playback capability (`UIBackgroundModes: audio`), seek controls, queue management, and lock screen/Dynamic Island metadata integration (`MPNowPlayingInfoCenter`).
- **`ContentView.swift`**: Tab navigation (Listen Now, Browse, Radio, Library, Search) featuring a dockable floating Mini Player.
- **`MiniPlayerView.swift`**: Sleek, persistent bottom player bar with play/pause and track progression.
- **`NowPlayingView.swift`**: Full-screen modal player featuring blurred dynamic background album art, responsive album artwork scaling on playback, interactive scrubber, and remote controls.
- **`LibraryView.swift`**: Categorized music library with recently played songs.

---

## 3. How to Build & Install on iPhone 15 Pro Max

Because iOS applications require Apple's compiler and code-signing infrastructure, you need a Mac or a cloud CI pipeline to generate the installable `.ipa` or run it directly on your iPhone 15 Pro Max.

### Option A: Direct Build with Xcode (Recommended)
1. Open this folder in Xcode on a Mac (or create a new iOS SwiftUI project named `kmusic` and import these Swift files).
2. Connect your **iPhone 15 Pro Max** via USB-C or Wi-Fi.
3. In Xcode, go to **Signing & Capabilities**:
   - Select your personal Apple ID under **Team** (free Apple Developer accounts are supported).
   - Bundle Identifier: `com.kmusic.player` (or your custom identifier).
4. Select your iPhone 15 Pro Max from the target device menu and click **Run** (`Cmd + R`).
5. On your iPhone: Go to **Settings > General > VPN & Device Management** and trust your Developer App certificate.

### Option B: Sideloading an IPA (Windows via Sideloadly or AltStore)
If you do not have direct access to a Mac:
1. Push this repository to GitHub.
2. Use a GitHub Actions workflow with `macos-latest` to build an unsigned or self-signed `.ipa` using `xcodebuild`.
3. Download the compiled `.ipa` artifact to your Windows PC.
4. Sideload the `.ipa` onto your iPhone 15 Pro Max using **Sideloadly** or **AltServer** with your Apple ID.

