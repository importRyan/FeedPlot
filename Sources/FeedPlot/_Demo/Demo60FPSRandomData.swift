//  © 2021 Ryan Ferrell. github.com/importRyan

import Foundation
import Combine
import simd

// MARK: - Demo hosted in a SwiftUI view

#if canImport(SwiftUI)
import SwiftUI

public struct DemoPlot: View {

    public init() {}

    @StateObject public var demo = Demo60FPS()

    public var body: some View {
        FeedPlotView(.drawWhenNotified, from: demo.dataStore) { [weak demo] metalViewReference in
            demo?.plot = metalViewReference
        }
        .frame(minWidth: 200, maxWidth: .infinity,
               minHeight: 200, maxHeight: .infinity)
    }
}
#endif

// MARK: - Data store

public class Demo60FPS: ObservableObject {

    /// Houses at least one frame's worth of fake "streaming"
    /// two dimensional data, providing it upon request to the Metal graph.
    let dataStore: (FPDataStore & FPDataProvider)
    weak var plot: FPMetalPlotView? = nil

    init() {
        self.dataStore = FPStreaming2DDataStore(
            bounds: FPBounds(xAxis: 0...10, yAxis: -5...5),
            dataPointsPerFrame: 3000
        )

        dataStore.addData(points: wideWave(at: 0, points: 1000, color: colors[0]))

        mimic60FPSInput()
    }

    /// Make fake data
    private var timer: AnyCancellable? = nil
    private var blueProgress: Float = 0
    private var goldProgress: Float = 0
    private let colors: [FPColor] = [.blue, .gold, .pink, .gray]


}


// MARK: - Generate Fake Data

public extension Demo60FPS {

    func addData(time: Date) {
        let lastX = dataStore.data.last?.point.x ?? 0
        let points = dataStore.dataPointsAllowedPerFrame
        let series1 = wideWave(at: lastX, points: points / 5, color: colors[0])
        let series2 = outOfSyncWave(at: lastX, points: points / 5, color: colors[1])
        dataStore.addData(points: series2 + series1)
    }

    func mimic60FPSInput() {
        timer = Timer.publish(every: 1/60, tolerance: 5/60, on: .current, in: .common, options: nil)
            .autoconnect()
            .sink { [weak self] time in
                self?.addData(time: time)
                if self?.plot?.drawMode != .drawAtMonitorFPS {
                    self?.plot?.updatePlot()
                }
            }
    }

    func wideWave(at lastX: Float, points: Int, color: FPColor) -> [FPColoredDataPoint] {

        var data: [FPColoredDataPoint] = []

        let stepX = dataStore.bounds.xAxis.range / Float(points) / 2
        let yRange = dataStore.bounds.yAxis.range

        for i in 1...points {
            let iFloat = Float(i)
            let x = lastX + (stepX * iFloat)

            blueProgress += 0.0001
            let progress = sin(blueProgress * 2 * .pi)
            let y = (progress * yRange) / 2
            data.append(.init(point: .init(x: x, y: y, z: 0), color: color))
        }

        if blueProgress > 10 { blueProgress = 0 }
        return data
    }

    func outOfSyncWave(at lastX: Float, points: Int, color: FPColor) -> [FPColoredDataPoint] {

        var data: [FPColoredDataPoint] = []

        let stepX = dataStore.bounds.xAxis.range / Float(points) / 2
        let yRange = dataStore.bounds.yAxis.range

        for i in 1...points {
            let iFloat = Float(i)
            let x = lastX + (stepX * iFloat)

            goldProgress += (1/60 / 10)
            let progress = cos(goldProgress * 2 * .pi)
            let y = (progress * yRange) / 10
            data.append(.init(point: .init(x: x, y: y, z: 0), color: color))
        }

        if goldProgress > 10 { goldProgress = 0 }
        return data
    }
}
