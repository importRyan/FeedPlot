//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation
import Combine

public protocol FPDataProvider: AnyObject {

    /// Returns data points for one frame, up to the provider's maximum,
    /// with bounds for that frame
    func getLatestData() -> (points: [FPColoredDataPoint], latestBounds: FPBounds)?

    /// Maximum data points to graph per frame
    var dataPointsPerFrame: Int { get }

    /// Per-axis bounds of stored data. Informs a plot how to
    /// scale points into a viewable area.
    var bounds: FPBounds { get }
}
