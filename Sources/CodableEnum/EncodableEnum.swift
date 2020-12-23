
import Foundation

public protocol EncodableEnum: Encodable { }

extension EncodableEnum {
    public func encode(to encoder: Encoder) throws {
        let cases = try encodableCases(of: Self.self)

        let bits = Int(ceil(log2(Double(cases.count))))
        let type = withUnsafeBytes(of: self) { Int($0.last!.mostSignificant(bits)) }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)

        try withUnsafeBytes(of: self) { bytes in
            let mutable = bytes.mutableCopy()
            mutable.storeBytes(of: bytes.last!.zeroMostSignificant(bits), toByteOffset: bytes.count - 1, as: UInt8.self)
            let address = UnsafeRawPointer(mutable.baseAddress!)

            let currentCases = cases[type]

            switch currentCases.count {
            case 1:
                let info = currentCases[0]
                let value = address.advanced(by: info.offset).unsafeLoad(as: info.type) as! Encodable
                try value.encode(to: &container, using: .data)
            case 2...:
                var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .data)
                for info in currentCases {
                    let value = address.advanced(by: info.offset).unsafeLoad(as: info.type) as! Encodable
                    try value.encode(to: &unkeyedContainer)
                }
            default:
                break
            }
        }
    }
}

extension Encodable {

    fileprivate func encode<T>(to container: inout KeyedEncodingContainer<T>, using key: T) throws {
        try container.encode(self, forKey: key)
    }


    fileprivate func encode(to container: inout UnkeyedEncodingContainer) throws {
        try container.encode(self)
    }

}
