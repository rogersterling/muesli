@preconcurrency import AVFoundation
import Foundation

final class MicrophoneRecorder: NSObject, AVAudioRecorderDelegate {
    enum RecordingEngine {
        case avAudioRecorder
        case streamingMicRecorder
    }

    private let streamingRecorder: StreamingMicRecorder?
    private var recorder: AVAudioRecorder?
    private var preparedURL: URL?

    init(recordingEngine: RecordingEngine = .avAudioRecorder) {
        switch recordingEngine {
        case .avAudioRecorder:
            self.streamingRecorder = nil
        case .streamingMicRecorder:
            self.streamingRecorder = StreamingMicRecorder(directoryName: "muesli-native")
        }
    }

    func prepare() throws {
        if let streamingRecorder {
            try streamingRecorder.prepare()
            return
        }
        if recorder != nil { return }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("muesli-native", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16_000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]
        let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()
        self.preparedURL = fileURL
        self.recorder = recorder
    }

    func start() throws {
        if let streamingRecorder {
            try streamingRecorder.start()
            return
        }
        try prepare()
        recorder?.record()
    }

    func stop() -> URL? {
        if let streamingRecorder {
            return streamingRecorder.stop()
        }
        guard let recorder else { return nil }
        recorder.stop()
        let url = preparedURL
        self.recorder = nil
        self.preparedURL = nil
        return url
    }

    func pause() {
        if let streamingRecorder {
            streamingRecorder.pause()
            return
        }
        recorder?.pause()
    }

    func resume() {
        if let streamingRecorder {
            streamingRecorder.resume()
            return
        }
        recorder?.record()
    }

    func currentPower() -> Float {
        if let streamingRecorder {
            return streamingRecorder.currentPower()
        }
        recorder?.updateMeters()
        return recorder?.averagePower(forChannel: 0) ?? -160
    }

    func cancel() {
        if let streamingRecorder {
            streamingRecorder.cancel()
            return
        }
        recorder?.stop()
        if let url = preparedURL {
            try? FileManager.default.removeItem(at: url)
        }
        recorder = nil
        preparedURL = nil
    }
}
