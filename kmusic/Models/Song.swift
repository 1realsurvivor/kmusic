import Foundation

struct Song: Identifiable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let coverUrl: String?
    let streamUrl: URL?

    init(id: UUID = UUID(), title: String, artist: String, album: String, duration: TimeInterval, coverUrl: String? = nil, streamUrl: URL? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.coverUrl = coverUrl
        self.streamUrl = streamUrl
    }
}

