
import Foundation
@_implementationOnly import Runtime

struct DecodableType {
    let offset: Int
    let type: Decodable.Type
}

private var decodableCases: [Int : [[DecodableType]]] = [:]
func decodableCases(of type: Any.Type) throws -> [[DecodableType]] {
    let key = unsafeBitCast(type, to: Int.self)
    if let cases = decodableCases[key] {
        return cases
    }

    let info = try typeInfo(of: type)
    guard case .enum = info.kind else { throw CodableEnumError.typeIsNotAnEnum(type) }
    let result = try info.cases.map { caseInType -> [DecodableType] in
        guard let type = caseInType.payloadType else {
            return []
        }

        return try decodableTypes(from: type)
    }

    decodableCases[key] = result
    return result
}

private func decodableTypes(from type: Any.Type, at path: [CodableEnumError.Path] = [], with offset: Int = 0) throws -> [DecodableType] {
    if let type = type as? Decodable.Type {
        return [DecodableType(offset: offset, type: type)]
    }

    let info = try typeInfo(of: type)
    if case .tuple = info.kind {
        return try info
            .properties
            .enumerated()
            .flatMap { element -> [DecodableType] in
                let (index, property) = element
                return try decodableTypes(from: property.type, at: path + [.int(index)], with: offset + property.offset)
            }
    }

    throw CodableEnumError.payloadTypeDoesNotConformToProtocol(path: path, type: type, expectedProtocolConformance: Encodable.self)
}
