// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2025-2026 Bain Gurley

import Testing
import Foundation
@testable import Rivulet

@Suite("EpisodePicker")
struct EpisodePickerTests {

    // MARK: - Builder

    // Static so it can build both `@Test` bodies and `arguments:` collections
    // (argument arrays are evaluated in a type-level context).
    private static func episode(
        _ id: String,
        season: Int? = 1,
        number: Int?,
        played: Bool = false,
        offset: TimeInterval = 0
    ) -> MediaItem {
        MediaItem(
            ref: MediaItemRef(providerID: "plex:test", itemID: id),
            kind: .episode,
            title: "Episode \(number.map(String.init) ?? "?")",
            sortTitle: nil,
            overview: nil,
            year: nil,
            runtime: 1800,
            parentRef: nil,
            grandparentRef: nil,
            episodeNumber: number,
            seasonNumber: season,
            childProgress: nil,
            userState: MediaUserState(
                isPlayed: played, viewOffset: offset, isFavorite: false, lastViewedAt: nil
            ),
            artwork: MediaArtwork(poster: nil, backdrop: nil, thumbnail: nil, logo: nil),
            parentArtwork: nil,
            grandparentArtwork: nil
        )
    }

    // MARK: - firstUnplayed

    struct FirstUnplayedCase: Sendable, CustomTestStringConvertible {
        let name: String
        let episodes: [MediaItem]
        let expectedID: String?
        var testDescription: String { name }
    }

    static let firstUnplayedCases: [FirstUnplayedCase] = [
        .init(name: "empty season returns nil", episodes: [], expectedID: nil),
        .init(name: "fresh season starts at episode one",
              episodes: [episode("e1", number: 1), episode("e2", number: 2)],
              expectedID: "e1"),
        .init(name: "skips watched episodes to first unplayed",
              episodes: [
                episode("e1", number: 1, played: true),
                episode("e2", number: 2, played: true),
                episode("e3", number: 3),
                episode("e4", number: 4),
              ],
              expectedID: "e3"),
        .init(name: "in-progress episode wins over later unplayed",
              episodes: [
                episode("e1", number: 1, played: true),
                episode("e2", number: 2, offset: 300),
                episode("e3", number: 3),
              ],
              expectedID: "e2"),
        .init(name: "fully watched season restarts at episode one",
              episodes: [
                episode("e1", number: 1, played: true),
                episode("e2", number: 2, played: true),
              ],
              expectedID: "e1"),
        .init(name: "played episode with resume offset is not in-progress",
              episodes: [
                episode("e1", number: 1, played: true, offset: 120),
                episode("e2", number: 2),
              ],
              expectedID: "e2"),
        .init(name: "unordered input is sorted before picking",
              episodes: [
                episode("e3", number: 3),
                episode("e1", number: 1, played: true),
                episode("e2", number: 2),
              ],
              expectedID: "e2"),
        .init(name: "sorts across seasons before episodes",
              episodes: [
                episode("s2e1", season: 2, number: 1),
                episode("s1e2", season: 1, number: 2),
                episode("s1e1", season: 1, number: 1, played: true),
              ],
              expectedID: "s1e2"),
        .init(name: "missing episode numbers fall back to server order",
              episodes: [
                episode("first", season: nil, number: nil, played: true),
                episode("second", season: nil, number: nil),
              ],
              expectedID: "second"),
    ]

    @Test("firstUnplayed picks the correct episode", arguments: firstUnplayedCases)
    func firstUnplayed(_ scenario: FirstUnplayedCase) {
        #expect(EpisodePicker.firstUnplayed(in: scenario.episodes)?.ref.itemID == scenario.expectedID)
    }

    // MARK: - nextUpLabel

    struct LabelCase: Sendable, CustomTestStringConvertible {
        let name: String
        let episode: MediaItem
        let expected: String?
        var testDescription: String { name }
    }

    static let labelCases: [LabelCase] = [
        .init(name: "next-up format",
              episode: episode("e3", season: 1, number: 3),
              expected: "Next Up: S1E3 · Episode 3"),
        .init(name: "resume label when in progress",
              episode: episode("e3", season: 2, number: 5, offset: 300),
              expected: "Resume: S2E5 · Episode 5"),
        .init(name: "nil without numbering",
              episode: episode("e1", season: nil, number: nil),
              expected: nil),
    ]

    @Test("nextUpLabel formats correctly", arguments: labelCases)
    func nextUpLabel(_ scenario: LabelCase) {
        #expect(EpisodePicker.nextUpLabel(for: scenario.episode) == scenario.expected)
    }

    // MARK: - isInProgress

    @Test("isInProgress semantics",
          arguments: [
            (MediaUserState(isPlayed: false, viewOffset: 0, isFavorite: false, lastViewedAt: nil), false),
            (MediaUserState(isPlayed: false, viewOffset: 60, isFavorite: false, lastViewedAt: nil), true),
            (MediaUserState(isPlayed: true, viewOffset: 0, isFavorite: false, lastViewedAt: nil), false),
            (MediaUserState(isPlayed: true, viewOffset: 60, isFavorite: false, lastViewedAt: nil), false),
          ])
    func isInProgress(_ state: MediaUserState, _ expected: Bool) {
        #expect(state.isInProgress == expected)
    }
}
