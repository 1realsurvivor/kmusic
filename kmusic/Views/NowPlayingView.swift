import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerService
    @Binding var isExpanded: Bool
    @State private var isDraggingSlider = false
    @State private var sliderValue: Double = 0

    var body: some View {
        ZStack {
            // Dynamic blurred background
            if let coverUrl = audioPlayer.currentSong?.coverUrl, let url = URL(string: coverUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 50)
                            .overlay(Color.black.opacity(0.55))
                            .ignoresSafeArea()
                    }
                }
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack(spacing: 24) {
                // Top Dismiss indicator
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }

                Spacer()

                // Album Artwork
                if let song = audioPlayer.currentSong {
                    AsyncImage(url: URL(string: song.coverUrl ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else {
                            Color.gray.opacity(0.4)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width - 64)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.6), radius: 24, y: 12)
                    .scaleEffect(audioPlayer.isPlaying ? 1.0 : 0.88)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: audioPlayer.isPlaying)
                }

                Spacer()

                // Song Title & Artist
                if let song = audioPlayer.currentSong {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(song.artist)
                                .font(.system(size: 19, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 32)
                }

                // Progress Bar & Timestamps
                VStack(spacing: 6) {
                    Slider(
                        value: Binding(
                            get: { isDraggingSlider ? sliderValue : audioPlayer.currentTime },
                            set: { newValue in
                                isDraggingSlider = true
                                sliderValue = newValue
                            }
                        ),
                        in: 0...max(audioPlayer.duration, 1),
                        onEditingChanged: { editing in
                            isDraggingSlider = editing
                            if !editing {
                                audioPlayer.seek(to: sliderValue)
                            }
                        }
                    )
                    .accentColor(.white)

                    HStack {
                        Text(formatTime(isDraggingSlider ? sliderValue : audioPlayer.currentTime))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("-\(formatTime(max(0, audioPlayer.duration - (isDraggingSlider ? sliderValue : audioPlayer.currentTime))))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)

                // Controls (Previous, Play/Pause, Next)
                HStack(spacing: 48) {
                    Button(action: { audioPlayer.previousSong() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }

                    Button(action: { audioPlayer.togglePlayPause() }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                    }

                    Button(action: { audioPlayer.nextSong() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 8)

                // Bottom Utilities
                HStack(spacing: 44) {
                    Button(action: {}) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Button(action: {}) {
                        Image(systemName: "airplayaudio")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Button(action: {}) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

