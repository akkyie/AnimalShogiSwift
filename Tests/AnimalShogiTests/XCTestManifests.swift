import XCTest

extension BoardTests {
    static let __allTests = [
        ("testDescription", testDescription),
        ("testDrop", testDrop),
        ("testGetSet", testGetSet),
        ("testMove", testMove),
        ("testPieces", testPieces),
        ("testPositions", testPositions),
    ]
}

extension ClientTests {
    static let __allTests = [
        ("testStart", testStart),
    ]
}

extension MessageTests {
    static let __allTests = [
        ("testClientMessageInitialization", testClientMessageInitialization),
        ("testServerMessageInitialization", testServerMessageInitialization),
    ]
}

extension PieceTests {
    static let __allTests = [
        ("testInitialization", testInitialization),
        ("testPromoted", testPromoted),
    ]
}

extension PositionTests {
    static let __allTests = [
        ("testDescription", testDescription),
    ]
}

extension StateTests {
    static let __allTests = [
        ("testReceived", testReceived),
    ]
}

#if !os(macOS)
    public func __allTests() -> [XCTestCaseEntry] {
        return [
            testCase(BoardTests.__allTests),
            testCase(ClientTests.__allTests),
            testCase(MessageTests.__allTests),
            testCase(PieceTests.__allTests),
            testCase(PositionTests.__allTests),
            testCase(StateTests.__allTests),
        ]
    }
#endif
