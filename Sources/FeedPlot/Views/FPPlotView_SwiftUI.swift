//  © 2021 Ryan Ferrell. github.com/importRyan

#if canImport(SwiftUI)
import SwiftUI
#if !targetEnvironment(macCatalyst) && canImport(AppKit)
typealias ViewHost = NSViewRepresentable
#else
typealias ViewHost = UIViewRepresentable
#endif

// MARK: - Hosting View

public struct FeedPlotView: ViewHost {

    public init(_ mode: FPMTKDrawMode,
                from dataProvider: FPDataProvider,
                connectPlot: @escaping (FPMetalPlotView) -> Void) {
        self.mode = mode
        self.dataProvider = dataProvider
        self.connectPlot = connectPlot
    }
    
    public let mode: FPMTKDrawMode
    public let dataProvider: FPDataProvider
    public let connectPlot: (FPMetalPlotView) -> Void

    public func makeView() -> FPMetalPlotView {
        let plot = FPMetalPlotView(mode: mode)
        plot.setData(provider: dataProvider)
        defer { connectPlot(plot) }
        return plot
    }
}

// MARK: - Make Hosting View in AppKit/UIKit

public extension FeedPlotView {
#if !targetEnvironment(macCatalyst) && canImport(AppKit)
    func makeNSView(context: Context) -> FPMetalPlotView {
        makeView()
    }

    func updateNSView(_ view: FPMetalPlotView, context: Context) {}
#else
    func makeUIView(context: Context) -> FPMetalPlotView {
        makeView()
    }

    func updateUIView(_ view: FPMetalPlotView, context: Context) {}
#endif
}
#endif
