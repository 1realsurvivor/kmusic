import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerService
    @State private var isNowPlayingExpanded: Bool = false
    @State private var selectedTab: Int = 3

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Text("Listen Now")
                    .tabItem {
                        Label("Listen Now", systemImage: "play.circle.fill")
                    }
                    .tag(0)

                Text("Browse")
                    .tabItem {
                        Label("Browse", systemImage: "square.grid.2x2.fill")
                    }
                    .tag(1)

                Text("Radio")
                    .tabItem {
                        Label("Radio", systemImage: "dot.radiowaves.left.and.right")
                    }
                    .tag(2)

                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "square.stack.fill")
                    }
                    .tag(3)

                Text("Search")
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(4)
            }
            .accentColor(.pink)

            // Floating MiniPlayer docked above the TabBar
            MiniPlayerView(isExpanded: $isNowPlayingExpanded)
                .padding(.bottom, 54)
        }
        .fullScreenCover(isPresented: $isNowPlayingExpanded) {
            NowPlayingView(isExpanded: $isNowPlayingExpanded)
        }
    }
}

