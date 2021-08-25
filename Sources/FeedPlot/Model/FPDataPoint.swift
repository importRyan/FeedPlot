//  © 2021 Ryan Ferrell. github.com/importRyan

import Foundation
import simd

public typealias FPPoint = SIMD3<Float>
public typealias FPSeriesIndex = Int
public typealias FPColor = SIMD4<Float>

public struct FPColoredDataPoint {

    public let point: FPPoint
    public let color: FPColor

    public init(point: FPPoint, color: FPColor) {
        self.point = point
        self.color = color
    }

}
