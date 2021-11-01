//  © 2021 Ryan Ferrell. github.com/importRyan

import MetalKit
import simd

var _metalDevice: MTLDevice!
var _metalLibrary: MTLLibrary!
var didSetupMetal = false

public func setupGlobalMetal() {
    didSetupMetal = true
    guard let device = MTLCreateSystemDefaultDevice()
    else { fatalError("The FeedPlot package failed to load Metal. Report this issue to the developer.") }
    guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module)
    else { fatalError("The FeedPlot package failed to load its Metal library. Report this issue to the developer.") }
    _metalDevice = device
    _metalLibrary = library
}

/// Draws a scatter plot that is scaled into the view bounds
/// by a Metal vertex shader. Each axis is inset by 5% to
/// ensure points at bounds are visible.
public class FPMetalPlotView: MTKView {

    private weak var data: FPDataProvider? = nil
    private var commandQueue: MTLCommandQueue!
    private var pipeline: MTLRenderPipelineState!

    public init(mode: FPMTKDrawMode, maxDataPoints: Int) {
        super.init(frame: .zero, device: nil)
        setupMetal(mode: mode)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Plot Methods

extension FPMetalPlotView: FPPlot {

    public func setData(provider: FPDataProvider) {
        data = provider
    }

    public func updateDrawMode(_ mode: FPMTKDrawMode) {
        mode.configure(mtkview: self)
        setNeedsDisplay(bounds)
    }

    public func updatePlot() {
        draw()
    }
}

// MARK: - Setup Metal

private extension FPMetalPlotView {

    func setupMetal(mode: FPMTKDrawMode) {
        clearColor = MTLClearColorMake(0, 0, 0, 0)
        #if !targetEnvironment(macCatalyst) && canImport(AppKit)
        layer?.backgroundColor = .clear
        layer?.isOpaque = false
        #else
        layer.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
        layer.isOpaque = false
        #endif

        delegate = self
        mode.configure(mtkview: self)

        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()!

        makeRenderPipelineState()

        #if !targetEnvironment(macCatalyst) && canImport(AppKit)
        needsDisplay = true
        #else
        setNeedsDisplay()
        #endif
    }

    func makeRenderPipelineState() {
        guard let library = try? device?.makeDefaultLibrary(bundle: Bundle.module)
        else { fatalError("The FeedPlot package failed to load its Metal library. Report this issue to the developer.") }
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "FPVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "FPFragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipeline = try! device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

}

// MARK: - Render

extension FPMetalPlotView: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Sizing is automatic
    }

    public func draw(in view: MTKView) {
        guard let (vertices, bounds, pointSize) = data?.getLatestData(),
              let descriptor = view.currentRenderPassDescriptor,
              let buffer = commandQueue.makeCommandBuffer(),
              let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        let vertexCount = vertices.countedByEndIndex()
        var vertexUniforms = FPVertexUniforms(bounds: bounds, pointSize: pointSize)

        encoder.setRenderPipelineState(pipeline)

        let vertexBuffer = device!.makeBuffer(
            bytes: vertices,
            length: vertexCount * MemoryLayout<FPColoredDataPoint>.stride,
            options: []
        )!

        encoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )

        encoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout.size(ofValue: vertexUniforms),
            index: 9
        )

        encoder.drawPrimitives(
            type: .point,
            vertexStart: 0,
            vertexCount: vertexCount
        )

        encoder.endEncoding()

        buffer.present(view.currentDrawable!)
        buffer.commit()
    }

}
