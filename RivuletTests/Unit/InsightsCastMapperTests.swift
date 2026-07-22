// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2025-2026 Bain Gurley

import Testing
import Foundation
@testable import Rivulet

@Suite("InsightsCastMapper")
struct InsightsCastMapperTests {

    @Test("TMDB mapping builds profile URL and character role")
    func tmdbMappingBuildsProfileURLAndCharacterRole() {
        let credit = TMDBCredit(id: 1, name: "Ellen Page", job: nil, department: nil,
                                character: "Ariadne", profilePath: "/abc.jpg")
        let people = InsightsCastMapper.mediaPeople(fromTMDB: [credit], titleTmdbId: 27205, titleIsMovie: true)
        #expect(people.count == 1)
        #expect(people[0].name == "Ellen Page")
        #expect(people[0].role == "Ariadne")
        #expect(people[0].imageURL?.absoluteString == "https://image.tmdb.org/t/p/w342/abc.jpg")
        #expect(people[0].titleTmdbId == 27205)
        #expect(people[0].titleIsMovie)
    }

    @Test("TMDB mapping drops nameless credits and handles nil profile")
    func tmdbMappingDropsNamelessAndHandlesNilProfile() {
        let nameless = TMDBCredit(id: 2, name: nil, job: nil, department: nil, character: "X", profilePath: nil)
        let noPhoto = TMDBCredit(id: 3, name: "Someone", job: nil, department: nil, character: nil, profilePath: nil)
        let people = InsightsCastMapper.mediaPeople(fromTMDB: [nameless, noPhoto], titleTmdbId: 1, titleIsMovie: false)
        #expect(people.count == 1)
        #expect(people[0].imageURL == nil)
    }

    @Test("Plex absolute thumb passes through unchanged")
    func plexAbsoluteThumbPassesThroughUnchanged() {
        // Plex person thumbs are often absolute metadata-CDN URLs; concatenating
        // serverURL onto them breaks the URL.
        let url = InsightsCastMapper.personThumbURL(
            "https://metadata-static.plex.tv/people/x.jpg",
            serverURL: "http://127.0.0.1:32400", authToken: "tok")
        #expect(url?.absoluteString == "https://metadata-static.plex.tv/people/x.jpg")
    }

    @Test("Plex relative thumb gets server and token")
    func plexRelativeThumbGetsServerAndToken() {
        let url = InsightsCastMapper.personThumbURL(
            "/library/metadata/1/thumb/2",
            serverURL: "http://127.0.0.1:32400", authToken: "tok")
        #expect(url?.absoluteString == "http://127.0.0.1:32400/library/metadata/1/thumb/2?X-Plex-Token=tok")
    }
}
