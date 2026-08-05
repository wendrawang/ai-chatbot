import QuartzCore

final class TanyaAIFrameRateMonitor: NSObject {
    private var displayLink: CADisplayLink?
    private var startTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    func start() {
        frameCount = 0
        startTimestamp = CACurrentMediaTime()
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(frameDidRender)
        )
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    func stop() -> Double {
        displayLink?.invalidate()
        displayLink = nil
        let duration = CACurrentMediaTime() - startTimestamp
        guard duration > 0 else {
            return 0
        }
        return Double(frameCount) / duration
    }

    @objc private func frameDidRender() {
        frameCount += 1
    }
}
