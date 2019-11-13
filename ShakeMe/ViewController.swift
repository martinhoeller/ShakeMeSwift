import UIKit
import WebKit
import Foundation
import AVFoundation

class ViewController: UIViewController, ShakeDetectorDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var sensitivitySlider: UISlider!
    @IBOutlet weak var sensitivityLabel: UILabel!

    private var player: AVAudioPlayer!
    private var playing = false
    private let shakeDetector = ShakeDetector()

    private var sensitivity = 5 {
        didSet {
            shakeDetector.sensitivity = sensitivity
            updateSensitivityLabel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        shakeDetector.delegate = self

        webView.isHidden = true
        loadGif()
        loadAudio()
        updateSensitivityLabel()
    }

    func shakeDetector(_ shakeDetector: ShakeDetector, didChangeShaking shaking: Bool) {
        if shaking {
            play()
        } else {
            pause()
        }
    }

    @IBAction func sensitivityChanged(_ sender: UISlider) {
        sensitivity = Int(sender.value)
    }
    
    private func loadGif() {
        guard let url = Bundle.main.url(forResource: "batman", withExtension: "gif") else { return }
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    private func loadAudio() {
        guard let url = Bundle.main.url(forResource: "batman_on_drugs", withExtension: "mp3") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.numberOfLoops = -1
        } catch let error {
            print(error)
        }
    }

    private func play() {
        playing = true
        webView.isHidden = false
        player.play()
    }

    private func pause() {
        playing = false
        webView.isHidden = true
        player.pause()
    }

    private func updateSensitivityLabel() {
        sensitivityLabel.text = "Sensitivity: \(sensitivity)"
    }
}
