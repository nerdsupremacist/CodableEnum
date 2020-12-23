
import Foundation

public enum CodableEnumError: Error {
    public enum Path {
        case string(String)
        case int(Int)
    }

    case typeIsNotAnEnum(Any.Type)
    case payloadTypeDoesNotConformToProtocol(path: [Path], type: Any.Type, expectedProtocolConformance: Any.Type)
    case enumTypeDoesNotHaveACaseNumber(Any.Type, Int)
}
