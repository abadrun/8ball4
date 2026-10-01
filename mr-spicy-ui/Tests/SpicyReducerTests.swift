//
//  SpicyReducerTests.swift
//  MR. SPICY — unit tests for the pure state layer and localization parity.
//
//  NOT EXECUTED in this environment (no macOS/Xcode toolchain available).
//  See documentation/validation.md for the honest validation status.
//

import XCTest
@testable import MrSpicyUI

final class SpicyReducerTests: XCTestCase {

    func testOpenExpands() {
        let state = SpicyReducer.reduce(SpicyState(), .open)
        XCTAssertEqual(state.presentation, .expanded)
    }

    func testCloseClearsModalAndSelection() {
        var state = SpicyState()
        state = SpicyReducer.reduce(state, .open)
        state = SpicyReducer.reduce(state, .selectFeature(.about))
        state = SpicyReducer.reduce(state, .close)
        XCTAssertEqual(state.presentation, .closed)
        XCTAssertNil(state.presentedModal)
        XCTAssertNil(state.selectedFeature)
    }

    func testEveryFeatureMapsToAModal() {
        for feature in SpicyFeature.allCases {
            let state = SpicyReducer.reduce(SpicyState(), .selectFeature(feature))
            XCTAssertNotNil(state.presentedModal, "\(feature) produced no modal")
        }
    }

    func testHidingOverlayAlsoCloses() {
        var state = SpicyReducer.reduce(SpicyState(), .open)
        state = SpicyReducer.reduce(state, .setOverlayVisible(false))
        XCTAssertEqual(state.presentation, .closed)
    }

    func testEntitlementDefaultsAreNotAuthoritative() {
        XCTAssertFalse(SpicyAccountState.unconfigured.pro.isAuthoritative)
        XCTAssertFalse(SpicyAccountState.unconfigured.license.isAuthoritative)
        XCTAssertFalse(SpicyEntitlementStatus.unverified.isAuthoritative)
        XCTAssertTrue(SpicyEntitlementStatus.verified(identifier: "x", expiry: nil).isAuthoritative)
    }

    func testReducerIsDeterministic() {
        let a = SpicyReducer.reduce(SpicyState(), .selectFeature(.settings))
        let b = SpicyReducer.reduce(SpicyState(), .selectFeature(.settings))
        XCTAssertEqual(a, b)
    }
}

final class SpicyLocalizationTests: XCTestCase {

    func testEveryKeyIsLocalizedInEveryLanguage() {
        for language in SpicyLanguage.allCases {
            let table = SpicyLocalization.fallback[language]
            XCTAssertNotNil(table, "missing table for \(language)")
            for key in SpicyStringKey.allCases {
                XCTAssertNotNil(table?[key], "missing \(key.rawValue) in \(language.rawValue)")
                XCTAssertFalse(table?[key]?.isEmpty ?? true, "empty \(key.rawValue) in \(language.rawValue)")
            }
        }
    }

    func testArabicIsRightToLeft() {
        XCTAssertTrue(SpicyLanguage.arabic.isRTL)
        XCTAssertFalse(SpicyLanguage.english.isRTL)
    }

    func testArabicStringsAreNotEnglishCopies() {
        let en = SpicyLocalization.fallback[.english] ?? [:]
        let ar = SpicyLocalization.fallback[.arabic] ?? [:]
        // Keys whose value is legitimately identical across languages (none today).
        let allowedIdentical: Set<SpicyStringKey> = []
        for key in SpicyStringKey.allCases where !allowedIdentical.contains(key) {
            XCTAssertNotEqual(en[key], ar[key], "untranslated key: \(key.rawValue)")
        }
    }
}

final class SpicyVersionTests: XCTestCase {

    func testOnlyTheInspectedHostBuildIsValidated() {
        XCTAssertTrue(SpicyVersion.isValidated(hostShortVersion: "56.30.0", build: "5328"))
        XCTAssertFalse(SpicyVersion.isValidated(hostShortVersion: "57.0.0", build: "5400"))
    }
}
