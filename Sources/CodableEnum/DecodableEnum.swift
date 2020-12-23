
import Foundation

public protocol DecodableEnum: Decodable { }

extension DecodableEnum {

    public init(from decoder: Decoder) throws {
        let cases = try decodableCases(of: Self.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(Int.self, forKey: .type)
        guard cases.indices.contains(type) else { throw CodableEnumError.enumTypeDoesNotHaveACaseNumber(Self.self, type) }
        let currentTypes = cases[type]


        let bitsEncodingCase = Int(ceil(log2(Double(cases.count))))
        let pointer = UnsafeMutablePointer<Self>.allocate(capacity: 1)
        let raw = UnsafeMutableRawPointer(pointer)

        switch currentTypes.count {
        case 1:
            try currentTypes[0].type.decode(from: container, using: .data, to: raw, at: 0)

        case 2...:
            var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .data)
            for type in currentTypes {
                try type.type.decode(from: &unkeyedContainer, to: raw, at: type.offset)
            }

        default:
            break
        }

        let offset = MemoryLayout<Self>.size - 1
        raw.storeBytes(of: raw.advanced(by: offset).load(as: UInt8.self).zeroMostSignificant(bitsEncodingCase) + (UInt8(type) << (8 - bitsEncodingCase)),
                       toByteOffset: offset,
                       as: UInt8.self)

        self = pointer.pointee
    }
}

extension Decodable {

    fileprivate static func decode<T>(from keyedContainer: KeyedDecodingContainer<T>, using key: T, to pointer: UnsafeMutableRawPointer, at offset: Int) throws {
        let decoded = try keyedContainer.decode(Self.self, forKey: key)
        pointer.storeBytes(of: decoded, toByteOffset: offset, as: Self.self)
    }

    fileprivate static func decode(from unkeyedContainer: inout UnkeyedDecodingContainer, to pointer: UnsafeMutableRawPointer, at offset: Int) throws {
        let decoded = try unkeyedContainer.decode(Self.self)
        pointer.storeBytes(of: decoded, toByteOffset: offset, as: Self.self)
    }

}
