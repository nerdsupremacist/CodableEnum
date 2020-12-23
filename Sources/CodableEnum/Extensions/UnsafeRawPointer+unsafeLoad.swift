
import Foundation

extension UnsafeRawPointer {

    func unsafeLoad(as type: Any.Type) -> Any {
        let fakeRecord = ProtocolConformanceRecord(type: type, witnessTable: 0)
        let loader = unsafeBitCast(fakeRecord, to: Loader.Type.self)
        return loader.load(from: self)
    }

}

protocol Loader { }
extension Loader {

    static func load(from pointer: UnsafeRawPointer) -> Any {
        return pointer.assumingMemoryBound(to: Self.self).pointee
    }

}

private struct ProtocolConformanceRecord {
    let type: Any.Type
    let witnessTable: Int
}
