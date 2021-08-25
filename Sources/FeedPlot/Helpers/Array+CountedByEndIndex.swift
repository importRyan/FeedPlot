//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

internal extension Array {

    func countedByEndIndex() -> Int {
        if endIndex > 1 {
            return endIndex
        } else {
            return isEmpty ? 0 : 1
        }
    }
}
