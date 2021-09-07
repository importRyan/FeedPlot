# FeedPlot
## Depict streaming sensor data feeds in resizable scatterplot rendered by Metal.

This package is an experimental stub to contrast with alternative options.

## How It Works

1. `FPDataStore` — Caches incoming series-colored data and vends a moving window of data

2. `FPMetalPlotView` — Renders recent data points at a rate you choose:
 - as fast as Metal deems ideal (e.g., 60/120 fps)
 - only when commanded (e.g., NSView.setNeedsDisplay() or FPMetalPlotView.updatePlot()) 
 - toggling between the above and paused (energy efficiency)
 
3. `FPShaders.metal` — Shaders scale data into (a) your explicit data bounds and (b) the current viewport pixel area

Optional: `FeedPlotView` — If using SwiftUI, this wraps the MTKView subclass above
Optional: `FPDataProvider` — Directly vend data points to `FPMetalPlotView` from your own cache

## Usage Sketch

Example output: A 2D scatterplot of incoming accelerometer data.
Y-axis: The amplitude of each of the three accelerometer axes, separately colored.
X-axis: Incremented by time point, but you could assign an epoch value instead.

1. `addPointInAllDataSeries()` A new data point is color-coded, assigned an x-value, and added to the cache
2. `FeedPlotView` Instructs Metal to render as fast as it wants, provides a data source to the `FPMetalPlotView` and offers a callback containing a reference to the `FPMetalPlotView` for you to store for later use if desired (e.g., to manually refresh the plot)
3. `updateYScale` An example of how to rescale the plot's data bounds. Calling `dataStore.setBounds()` ensures the `FPDataStore` vends the new bounds for the next render pass and asks the `FPMetalPlotView` to redraw itself if in a paused state. Scaling is non-destructive: points that are outside of the new bounds simply won't appear in the rendered viewport.

```
struct FeedPlotFixedSize: View {

    @StateObject var controller: FeedPlotController 
    // or simply pass an otherwise retained object

    let size: CGSize

    var body: some View {
        FeedPlotView(.drawAtMonitorFPS, from: controller.dataStore) { [weak controller] in
            controller?.plot = $0
        }
        .frame(width: size.width, height: size.height)
    }

}

class FeedPlotController: ObservableObject {

    public weak var plot: FPPlot? = nil
    private let dataStore: (FPDataProvider & FPDataStore)
    public private(set) var seriesColors: [FPColor]

}

extension FeedPlotController: GraphController {

    public func addPointInAllSeries(_ point: [Float]) {
        let lastX = dataStore.data.last?.point.x ?? 0
        let newX = Float(latestX + 1)
        let points = zip(point.indices, point).map { (index, y) in
            FPColoredDataPoint(point: .init(x: latest, y: y, z: 0), color: seriesColors[index])
        }
        dataStore.addData(points: points)
    }

    public func updateYScale(min: Double, max: Double) {
        var bounds = dataStore.bounds
        bounds.yAxis = Float(min)...Float(max)
        dataStore.setBounds(bounds)
        plot?.updatePlot()
    }

}

```

