
import Foundation
@_implementationOnly import Runtime

struct EncodableType {
    let offset: Int
    let type: Encodable.Type
}

private var encodableCases: [Int : [[EncodableType]]] = [:]
func encodableCases(of type: Any.Type) throws -> [[EncodableType]] {
    let key = unsafeBitCast(type, to: Int.self)
    if let cases = encodableCases[key] {
        return cases
    }

    let info = try typeInfo(of: type)
    guard case .enum = info.kind else { throw CodableEnumError.typeIsNotAnEnum(type) }
    let result = try info.cases.map { caseInType -> [EncodableType] in
        guard let type = caseInType.payloadType else {
            return []
        }

        return try encodableTypes(from: type)
    }

    encodableCases[key] = result
    return result
}

private func encodableTypes(from type: Any.Type, at path: [CodableEnumError.Path] = [], with offset: Int = 0) throws -> [EncodableType] {
    if let type = type as? Encodable.Type {
        return [EncodableType(offset: offset, type: type)]
    }

    let info = try typeInfo(of: type)
    if case .tuple = info.kind {
        return try info
            .properties
            .enumerated()
            .flatMap { element -> [EncodableType] in
                let (index, property) = element
                return try encodableTypes(from: property.type, at: path + [.int(index)], with: offset + property.offset)
            }
    }

    throw CodableEnumError.payloadTypeDoesNotConformToProtocol(path: path, type: type, expectedProtocolConformance: Encodable.self)
}
