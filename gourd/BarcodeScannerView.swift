//
//  BarcodeScannerView.swift
//  gourd
//
//  AVFoundation barcode scanner wrapped as a SwiftUI view.
//

import SwiftUI
import AVFoundation

// MARK: - SwiftUI Wrapper

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onDetected: (String) -> Void
    @Binding var isPaused: Bool
    @Binding var torchOn: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> BarcodeScannerController {
        let controller = BarcodeScannerController()
        controller.onDetected = onDetected
        return controller
    }

    func updateUIViewController(_ controller: BarcodeScannerController, context: Context) {
        if isPaused {
            controller.isPaused = true
            context.coordinator.wasPaused = true
        } else if context.coordinator.wasPaused {
            // Transition from paused → unpaused: explicitly resume
            controller.resumeScanning()
            context.coordinator.wasPaused = false
        }
        controller.setTorch(torchOn)
    }

    final class Coordinator {
        var wasPaused = false
    }
}

// MARK: - UIViewController

final class BarcodeScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var onDetected: ((String) -> Void)?
    var isPaused = false

    private let session      = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var captureDevice: AVCaptureDevice?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning { self.session.stopRunning() }
        }
        setTorch(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Setup

    private func setupSession() {
        // High preset = more pixels = more reliable barcode reads
        session.sessionPreset = .high

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        captureDevice = device
        session.addInput(input)

        // Configure camera for best barcode performance
        configureCameraForScanning(device)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [
            .ean13, .ean8, .upce,
            .code128, .code39, .code93,
            .itf14, .pdf417, .qr
        ]

        // Focus the metadata processing on the center scan zone
        // (coordinates are in 0–1 normalized layer space, origin top-left)
        output.rectOfInterest = CGRect(x: 0.25, y: 0.3, width: 0.5, height: 0.4)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)
        previewLayer = preview

        // Re-focus when subject changes (user moves camera)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subjectAreaDidChange),
            name: AVCaptureDevice.subjectAreaDidChangeNotification,
            object: device
        )
    }

    private func configureCameraForScanning(_ device: AVCaptureDevice) {
        try? device.lockForConfiguration()
        // Continuous autofocus keeps barcode sharp as distance changes
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        // Continuous auto-exposure handles bright/dark environments
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        // Notify us when subject area changes so we can re-focus
        device.isSubjectAreaChangeMonitoringEnabled = true
        device.unlockForConfiguration()
    }

    @objc private func subjectAreaDidChange() {
        guard let device = captureDevice else { return }
        try? device.lockForConfiguration()
        // Re-focus at center of frame
        let center = CGPoint(x: 0.5, y: 0.5)
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = center
            device.focusMode = .continuousAutoFocus
        }
        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = center
            device.exposureMode = .continuousAutoExposure
        }
        device.unlockForConfiguration()
    }

    // MARK: Torch

    func setTorch(_ on: Bool) {
        guard
            let device = captureDevice ?? AVCaptureDevice.default(for: .video),
            device.hasTorch
        else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    // MARK: Resume

    func resumeScanning() {
        isPaused = false
    }

    // MARK: Detection Delegate

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            !isPaused,
            let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let barcode = obj.stringValue
        else { return }

        isPaused = true
        onDetected?(barcode)
    }
}
