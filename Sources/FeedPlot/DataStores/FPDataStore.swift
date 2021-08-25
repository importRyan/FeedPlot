//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public protocol FPDataStore: AnyObject {

    var data: [FPColoredDataPoint] { get }
    var dataPointCount: Int { get }
    var dataPointsAllowedPerFrame: Int { get }

    /// Sorted from low to high X values
    func addData(points: [FPColoredDataPoint])
}
