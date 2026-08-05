import QuartzCore

final class TanyaAIFrameRateMonitor: NSObject {
    private var displayLink: CADisplayLink?
    private var timestamps: [CFTimeInterval] = []

    func start() {
        timestamps.removeAll(keepingCapacity: true)
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
        guard let firstTimestamp = timestamps.first,
              let lastTimestamp = timestamps.last,
              timestamps.count > 1 else {
            return 0
        }
        let duration = lastTimestamp - firstTimestamp
        guard duration > 0 else {
            return 0
        }
        return Double(timestamps.count - 1) / duration
    }

    @objc private func frameDidRender(_ displayLink: CADisplayLink) {
        timestamps.append(displayLink.timestamp)
    }
}
