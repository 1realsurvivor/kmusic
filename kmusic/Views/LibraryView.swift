import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerService

    let sections = [
        ("Playlists", "music.note.list"),
        ("Artists", "music.mic"),
        ("Albums", "square.stack"),
        ("Songs", "music.note"),
        ("Downloaded", "arrow.down.circle")
    ]

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(sections, id: \.0) { item in
                        HStack(spacing: 16) {
                            Image(systemName: item.1)
                                .font(.system(size: 20))
                                .foregroundColor(.pink)
                                .frame(width: 28)
                            Text(item.0)
                                .font(.system(size: 18, weight: .regular))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Recently Added").font(.title2).bold().foregroundColor(.primary)) {
                    ForEach(audioPlayer.queue) { song in
                        Button(action: {
                            audioPlayer.play(song: song)
                        }) {
                            HStack(spacing: 14) {
                                AsyncImage(url: URL(string: song.coverUrl ?? "")) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .frame(width: 48, height: 48)
                                .cornerRadius(6)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(song.title)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(audioPlayer.currentSong?.id == song.id ? .pink : .primary)
                                        .lineLimit(1)
                                    Text("\(song.artist) • \(song.album)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                if audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying {
                                    Image(systemName: "waveform")
                                        .foregroundColor(.pink)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Library")
        }
    }
}

