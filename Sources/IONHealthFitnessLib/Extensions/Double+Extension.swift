import Foundation

extension Double {
    // Rounds floating point values to avoid precision issues when
    // serializing to JavaScript numbers (e.g. 0.26900000000000013 -> 0.269)
    // ensuring compatibility with JavaScript safe decimal limits.
    func jsSafe(decimals: Int = 4) -> Double {
        let factor = pow(10.0, Double(decimals))
        return (self * factor).rounded() / factor
    }
}

