import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    private var player: AVPlayer?
    private var timeObserverToken: Any?

    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var queue: [Song] = []
    @Published var currentIndex: Int = 0

    init() {
        configureAudioSession()
        setupRemoteCommandCenter()
        loadSampleLibrary()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }

    private func loadSampleLibrary() {
        queue = [
            Song(
                title: "Cosmic Odyssey",
                artist: "Starlight Echo",
                album: "Celestial Horizons",
                duration: 215,
                coverUrl: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop&q=80",
                streamUrl: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
            ),
            Song(
                title: "Neon Horizon",
                artist: "Cyber Drift",
                album: "Retrowave City",
                duration: 184,
                coverUrl: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80",
                streamUrl: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")
            ),
            Song(
                title: "Midnight Rain",
                artist: "Luna Sol",
                album: "Atmospheric Memories",
                duration: 242,
                coverUrl: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80",
                streamUrl: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3")
            )
        ]
        if let first = queue.first {
            currentSong = first
            duration = first.duration
        }
    }

    func play(song: Song) {
        if let index = queue.firstIndex(of: song) {
            currentIndex = index
        }
        currentSong = song
        duration = song.duration

        guard let url = song.streamUrl else { return }

        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let currentDuration = self.player?.currentItem?.duration.seconds, !currentDuration.isNaN, currentDuration > 0 {
                self.duration = currentDuration
            }
            self.updateNowPlayingInfo()
        }

        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil, let song = currentSong {
                play(song: song)
            } else {
                player?.play()
                isPlaying = true
            }
        }
        updateNowPlayingInfo()
    }

    func nextSong() {
        guard !queue.isEmpty else { return }
        currentIndex = (currentIndex + 1) % queue.count
        play(song: queue[currentIndex])
    }

    func previousSong() {
        guard !queue.isEmpty else { return }
        if currentTime > 3.0 {
            seek(to: 0)
        } else {
            currentIndex = (currentIndex - 1 + queue.count) % queue.count
            play(song: queue[currentIndex])
        }
    }

    func seek(to time: TimeInterval) {
        currentTime = time
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        updateNowPlayingInfo()
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextSong()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousSong()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let posEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: posEvent.positionTime)
                return .success
            }
            return .commandFailed
        }
    }

    private func updateNowPlayingInfo() {
        guard let song = currentSong else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }
}

