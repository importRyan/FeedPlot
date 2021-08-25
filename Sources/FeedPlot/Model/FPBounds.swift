//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public struct FPBounds {

    /// Recommended display bounds for data stored
    public var xAxis: ClosedRange<Float>

    /// Recommended display bounds for data stored
    public var yAxis: ClosedRange<Float>

    /// Recommended display bounds for data stored
    /// For 2D graphs, use the default value.
    public var zAxis: ClosedRange<Float> = .twoDimensionalPlot

    /// Recommended display bounds for data. A plot will use
    /// these bounds to scale points into a viewable area.
    public init(xAxis: ClosedRange<Float>,
                yAxis: ClosedRange<Float>,
                zAxis: ClosedRange<Float> = .twoDimensionalPlot) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.zAxis = zAxis
    }

    /// Scrolls x-axis bounds to a maximum value, preserving prior range.
    func scrolledTo(x: Float) -> Self {
        var newBounds = self
        newBounds.xAxis = (x - xAxis.range)...x
        return newBounds
    }
}

public extension ClosedRange where Bound == Float {

    static let twoDimensionalPlot: ClosedRange<Float> = 0...1

    var range: Bound { abs(upperBound - lowerBound) }
}
