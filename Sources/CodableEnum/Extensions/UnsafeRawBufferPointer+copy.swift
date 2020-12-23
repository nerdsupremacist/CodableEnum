
import Foundation

extension UnsafeRawBufferPointer {

    func mutableCopy() -> UnsafeMutableRawBufferPointer {
        let pointer = UnsafeMutableRawBufferPointer.allocate(byteCount: count, alignment: MemoryLayout<UInt8>.alignment)
        pointer.copyMemory(from: self)
        return pointer
    }

}
