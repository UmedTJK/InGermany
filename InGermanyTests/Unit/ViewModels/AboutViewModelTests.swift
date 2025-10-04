//
//  AboutViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class AboutViewModelTests: XCTestCase {
    var sut: AboutViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = AboutViewModel()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertNotNil(sut.appVersion, "App version should not be nil")
        XCTAssertNotNil(sut.buildNumber, "Build number should not be nil")
        XCTAssertEqual(sut.repositoryURL, "https://github.com/UmedTJK/InGermany", "Repository URL should be correct")
    }
    
    func testVersionAndBuildFormat() {
        // Given - initialized view model
        
        // When - check version and build format
        let version = sut.appVersion
        let build = sut.buildNumber
        
        // Then - should have valid format
        XCTAssertFalse(version.isEmpty, "Version should not be empty")
        XCTAssertFalse(build.isEmpty, "Build number should not be empty")
        
        // Version should be semantic version-like (e.g., "1.0", "1.12.0")
        let versionPattern = #"^\d+\.\d+(\.\d+)?$"#
        let buildPattern = #"^\d+$"#
        
        // Более мягкая проверка для тестовой среды
        XCTAssertTrue(version.range(of: versionPattern, options: .regularExpression) != nil ||
                     version == "1.0", "Version should follow semantic versioning pattern or be default")
        
        XCTAssertTrue(build.range(of: buildPattern, options: .regularExpression) != nil ||
                     build == "1", "Build number should be numeric or be default")
    }
    
    func testRepositoryURL() {
        // Given - initialized view model
        
        // When - check repository URL
        let url = sut.repositoryURL
        
        // Then - should be valid GitHub URL
        XCTAssertTrue(url.hasPrefix("https://github.com/"), "Should be a GitHub URL")
        XCTAssertTrue(url.contains("UmedTJK/InGermany"), "Should point to correct repository")
        
        // Should be valid URL format
        XCTAssertNotNil(URL(string: url), "Repository URL should be valid URL format")
    }
    
    func testBundleInfoLoading() {
        // Given - initialized view model
        
        // When - check if bundle info was loaded
        let version = sut.appVersion
        let build = sut.buildNumber
        
        // Then - should have loaded values (могут быть значения по умолчанию в тестовой среде)
        XCTAssertFalse(version.isEmpty, "App version should have a value")
        XCTAssertFalse(build.isEmpty, "Build number should have a value")
        
        // В тестовой среде значения могут быть по умолчанию, это нормально
        print("App Version: \(version), Build: \(build)")
    }
    
    func testDefaultValues() {
        // Test that default values are reasonable fallbacks
        let viewModel = AboutViewModel()
        
        XCTAssertFalse(viewModel.appVersion.isEmpty, "App version should have a value")
        XCTAssertFalse(viewModel.buildNumber.isEmpty, "Build number should have a value")
        XCTAssertFalse(viewModel.repositoryURL.isEmpty, "Repository URL should have a value")
    }
    
    func testRepositoryURLIsValid() {
        // Given
        let viewModel = AboutViewModel()
        
        // When
        let urlString = viewModel.repositoryURL
        
        // Then
        let url = URL(string: urlString)
        XCTAssertNotNil(url, "Repository URL should be a valid URL")
        XCTAssertEqual(url?.host, "github.com", "Should point to GitHub")
    }
}
