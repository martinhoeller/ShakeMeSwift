import Foundation
import CoreMotion

protocol ShakeDetectorDelegate: class {
    func shakeDetector(_ shakeDetector: ShakeDetector, didChangeShaking shaking: Bool)
}

class ShakeDetector {
    weak var delegate: ShakeDetectorDelegate?

    private let motionManager = CMMotionManager()

    private var xAccel = 0.0
    private var yAccel = 0.0
    private var zAccel = 0.0
    private var initialized = false

    private var previousNoise = [Double]()
    private let maxNoiseCount = 3

    private(set) var isShaking = false {
        didSet {
            delegate?.shakeDetector(self, didChangeShaking: isShaking)
        }
    }

    var sensitivity = 5

    init() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            guard let data = data else { return }
            self.handleAccelerometerData(data)
        }
    }

    private func handleAccelerometerData(_ data: CMAccelerometerData) {
        if !initialized {
            xAccel = data.acceleration.x
            yAccel = data.acceleration.y
            zAccel = data.acceleration.z
            initialized = true
        } else {
            let dAX = xAccel - data.acceleration.x
            let dAY = yAccel - data.acceleration.y
            let dAZ = zAccel - data.acceleration.z
            let noiseVector = sqrt(pow(dAX, 2) + pow(dAY, 2) + pow(dAZ, 2))

            xAccel = data.acceleration.x
            yAccel = data.acceleration.y
            zAccel = data.acceleration.z
            previousNoise.append(noiseVector)
            while previousNoise.count > maxNoiseCount {
                previousNoise.remove(at: 0)
            }

            let sum = previousNoise.reduce(0, +)
            let currentNoise = sum / Double(maxNoiseCount)
            let noiseThreshold = Double(10 - sensitivity)

            if previousNoise.count == maxNoiseCount && !isShaking {
                if currentNoise > noiseThreshold {
                    isShaking = true
                }
            } else if isShaking {
                if currentNoise < noiseThreshold {
                    isShaking = false
                }
            }
        }
    }
}
