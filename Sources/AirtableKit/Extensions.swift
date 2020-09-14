import Foundation

extension Array {
    
    /// Groups the elements of the receiver by forming arrays of max size `chunkSize`.
    ///
    /// Example:
    ///
    ///     [1, 2, 3, 4, 5].chunked(by: 2) == [[1, 2], [3, 4], [5]]
    ///
    /// Reference: https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
    ///
    /// - Precondition: `chunkSize > 0`
    /// - Parameter chunkSize: Maximum size of each chunk.
    /// - Returns: The same elements of the receiver, grouped into chunks of at most `chunkSize` elements.
    func chunked(by chunkSize: Int) -> [[Element]] {
        precondition(chunkSize > 0)
        
        return stride(from: startIndex, to: endIndex, by: chunkSize).map {
            Array(self[$0 ..< Swift.min(index($0, offsetBy: chunkSize), endIndex)])
        }
    }
}
