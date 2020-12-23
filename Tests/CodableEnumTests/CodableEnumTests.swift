import XCTest
@testable import CodableEnum

final class CodableEnumTests: XCTestCase {
    enum SimpleEnum: CodableEnum {
        case one(String)
        case two(String)
    }

    struct MyStruct: Codable, Equatable {
        let int: Int
        let bool: Bool
    }

    enum MoreComplexEnum: CodableEnum, Equatable {
        case one(String)
        case two(String, MyStruct)
        case three(MyStruct)
    }

    func testExample() throws {
        let original = MoreComplexEnum.two("Hello", MyStruct(int: 42, bool: true))
        let encoded = try JSONEncoder().encode(original)
        print(String(data: encoded, encoding: .utf8))
        let decoded = try JSONDecoder().decode(MoreComplexEnum.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }
}
