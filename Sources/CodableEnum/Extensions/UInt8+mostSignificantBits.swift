
import Foundation

extension UInt8 {

    func zeroMostSignificant(_ bits: Int) -> UInt8 {
        let shape = UInt8.max >> bits
        return self & shape
    }

    func mostSignificant(_ bits: Int) -> UInt8 {
        let shift = Self(MemoryLayout<UInt8>.size * 8 - bits)
        let shape = UInt8.max >> (MemoryLayout<UInt8>.size * 8 - bits)
        return (self >> shift) & shape
    }

}
