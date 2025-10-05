import XCTest
import Combine
@testable import InGermany

@MainActor
final class RatingManagerTests: XCTestCase {
    
    private var sut: RatingManager!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = RatingManager.shared
        cancellables = []
        sut.clearForTesting()
    }
    
    override func tearDown() {
        sut.clearForTesting()
        cancellables = []
        super.tearDown()
    }
    
    // ... остальные тесты остаются без изменений ...
    
    func test_threadSafety_concurrentAccess() async {
        // Given
        let operationsCount = 100
        let concurrentQueues = 5
        
        await withTaskGroup(of: Void.self) { group in
            for queueIndex in 0..<concurrentQueues {
                group.addTask {
                    for operationIndex in 0..<operationsCount {
                        let articleId = "concurrent-\(queueIndex)-\(operationIndex)"
                        let rating = (queueIndex + operationIndex) % 6
                        
                        // ✅ Все вызовы теперь безопасны благодаря @MainActor
                        await RatingManager.shared.setRating(rating, for: articleId)
                        let retrievedRating = await RatingManager.shared.getRating(for: articleId)
                        XCTAssertEqual(retrievedRating, rating)
                    }
                }
            }
        }
    }
}
