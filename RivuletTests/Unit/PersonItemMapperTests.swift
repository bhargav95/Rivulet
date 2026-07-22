// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2025-2026 Bain Gurley

import Testing
import Foundation
@testable import Rivulet

@Suite("PersonItemMapper")
struct PersonItemMapperTests {
    @Test("builds metadata-only movie item")
    func buildsMetadataOnlyMovieItem() {
        let url = URL(string: "https://metadata-static.plex.tv/p/poster.jpg")!
        let item = PersonItemMapper.metadataOnlyItem(
            tmdbId: 1234, isMovie: true, title: "The Town", year: 2010,
            posterURL: url, overview: "Bank robbers.")
        #expect(item.isMetadataOnly)
        #expect(item.tmdbID == 1234)
        #expect(item.kind == .movie)
        #expect(item.title == "The Town")
        #expect(item.year == 2010)
        #expect(item.artwork.poster == url)
    }

    @Test("builds metadata-only show item")
    func buildsMetadataOnlyShowItem() {
        let item = PersonItemMapper.metadataOnlyItem(
            tmdbId: 99, isMovie: false, title: "Mad Men", year: 2007,
            posterURL: nil, overview: nil)
        #expect(item.kind == .show)
        #expect(item.tmdbID == 99)
        #expect(item.artwork.poster == nil)
    }
}
