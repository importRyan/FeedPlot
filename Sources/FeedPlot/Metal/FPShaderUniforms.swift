//  © 2021 Ryan Ferrell. github.com/importRyan

import Foundation

public struct FPVertexUniforms {

    public var startX: Float
    public var endX: Float
    public var startY: Float
    public var endY: Float
    public var startZ: Float
    public var endZ: Float

    public init(startX: Float, endX: Float, startY: Float, endY: Float, startZ: Float, endZ: Float) {
        self.startX = startX
        self.endX = endX
        self.startY = startY
        self.endY = endY
        self.startZ = startZ
        self.endZ = endZ
    }

    public init(bounds: FPBounds) {
        self.startX = bounds.xAxis.lowerBound
        self.endX = bounds.xAxis.upperBound
        self.startY = bounds.yAxis.lowerBound
        self.endY = bounds.yAxis.upperBound
        self.startZ = bounds.zAxis.lowerBound
        self.endZ = bounds.zAxis.upperBound
    }

    /// Defaults to 0...1 2D plot
    public init(defaultingTo2DBounds bounds: FPBounds?) {
        self.init(bounds: bounds ?? FPBounds(xAxis: 0...1, yAxis: 0...1))
    }
}
