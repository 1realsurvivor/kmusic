import SwiftUI

@main
struct kmusicApp: App {
    @StateObject private var audioPlayer = AudioPlayerService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayer)
                .preferredColorScheme(.dark)
        }
    }
}

