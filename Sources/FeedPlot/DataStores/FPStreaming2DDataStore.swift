//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation
import simd

open class FPStreaming2DDataStore {

    /// Ordered by time of arrival
    public private(set) var data: [FPColoredDataPoint] = []

    /// A limited number of the most recent data points, regardless
    /// of series membership, are collected for rendering.
    public private(set) var dataPointsAllowedPerFrame: Int

    /// An approximate maximum number of data points to store in memory.
    public private(set) lazy var dataPointCacheMaxSize: Int = dataPointsAllowedPerFrame * 30

    /// Recommended display bounds for data. A plot will use
    /// these bounds to scale points into a viewable area.
    public private(set) var bounds: FPBounds

    /// Initialize with empty or preset data
    public init(data: [FPColoredDataPoint] = [],
                bounds: FPBounds,
                dataPointsPerFrame: Int) {
        self.data = data
        self.dataPointsAllowedPerFrame = dataPointsPerFrame
        self.bounds = bounds
    }

    func enforceMaxSize() {
        guard dataPointCount > dataPointCacheMaxSize else { return }
        data = Array(data[(dataPointCount - dataPointCacheMaxSize)...])
    }

}

extension FPStreaming2DDataStore: FPDataProvider {

    public func getLatestData() -> (points: [FPColoredDataPoint], latestBounds: FPBounds)? {
        guard !data.isEmpty else { return nil }

        let minIndex = max(0, data.endIndex - dataPointsAllowedPerFrame)
        let scrolledBounds = bounds.scrolledTo(x: data.last!.point.x)

        return (
            points: Array(data[minIndex...]),
            latestBounds: scrolledBounds
        )
    }

    public var dataPointsPerFrame: Int {
        min(dataPointCount, dataPointsAllowedPerFrame)
    }

}

extension FPStreaming2DDataStore: FPDataStore {

    public func clearData() {
        data = []
    }


    public func setBounds(_ newBounds: FPBounds) {
        bounds = newBounds
    }

    /// Ordered from low to high X values
    public func addData(points: [FPColoredDataPoint]) {

        /// Simply set if incoming data is beyond cache limit
        if points.endIndex > dataPointCacheMaxSize {
            data = points
            return
        }

        /// Append data when not full
        if data.isEmpty || data.endIndex + points.endIndex < dataPointCacheMaxSize {
            data.append(contentsOf: points)
            return
        }

        /// Roughly right-size data to not grossly exceed the storage ceiling
        var newData = Array(data.suffix(dataPointsPerFrame))
        newData.append(contentsOf: points)
        data = newData
    }

    public var dataPointCount: Int { data.countedByEndIndex() }
}
