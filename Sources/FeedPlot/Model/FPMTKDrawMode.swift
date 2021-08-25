//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation
import MetalKit

public enum FPMTKDrawMode {

    /// Redraws as fast as useful (MTKView.preferredFramesPerSecond)
    case drawAtMonitorFPS

    /// Redraws on command. Call setNeedsDisplay() or this framework's FPPlot.updatePlot().
    case drawWhenNotified

    /// Redraws on render command. Call MTKView.draw() or this framework's FPPlot.updatePlot()
    case drawOnExplicitCommand

    public func configure(mtkview: MTKView) {
        switch self {
            case .drawAtMonitorFPS:
                mtkview.isPaused = false
                mtkview.enableSetNeedsDisplay = false

            case .drawWhenNotified:
                mtkview.isPaused = true
                mtkview.enableSetNeedsDisplay = true

            case .drawOnExplicitCommand:
                mtkview.isPaused = true
                mtkview.enableSetNeedsDisplay = false
        }
    }

    init?(mtkview: MTKView) {

        if !mtkview.isPaused && !mtkview.enableSetNeedsDisplay {
            self = .drawAtMonitorFPS

        } else if mtkview.isPaused, mtkview.enableSetNeedsDisplay {
            self = .drawWhenNotified

        } else if mtkview.isPaused, !mtkview.enableSetNeedsDisplay {
            self = .drawOnExplicitCommand

        } else {
            return nil
        }
    }
}

extension MTKView {
    var drawMode: FPMTKDrawMode? { .init(mtkview: self) }
}
