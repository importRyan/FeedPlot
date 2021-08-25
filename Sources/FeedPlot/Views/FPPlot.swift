//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation
import MetalKit

public protocol FPPlot: MTKView {

    /// Source for data points to plot
    func setData(provider: FPDataProvider)

    /// Change the draw schedule of the MTKView (e.g., on manual update or at the maximum visible frame rate)
    func updateDrawMode(_ mode: FPMTKDrawMode)

    /// When in a manual MTKDrawMode, this method asks the plot to perform a render pass when ready.
    func updatePlot()

}
