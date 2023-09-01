import UIKit
import AVFoundation
import Vision

final class CameraViewController: UIViewController {
  
  private var drawings: [CAShapeLayer] = []
  
  
  
  private let videoDataOutput = AVCaptureVideoDataOutput()
  private let captureSession = AVCaptureSession()
  

  
  /// Using `lazy` keyword because the `captureSession` needs to be loaded before we can use the preview layer.
  private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
  
  private var gameLogicController = GameLogicController()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addCameraInput()
    showCameraFeed()
    
    getCameraFrames()
    captureSession.startRunning()
  }
  

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer.frame = view.frame
  }
  
  private func addCameraInput() {
    print("add camer Input func start!!")
    guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front).devices.first else {
      fatalError("No camera detected. Please use a real camera, not a simulator.")
    }
    
    // ⚠️ You should wrap this in a `do-catch` block, but this will be good enough for the demo.
    let cameraInput = try! AVCaptureDeviceInput(device: device)
    if captureSession.inputs.isEmpty {
        captureSession.addInput(cameraInput)
    }
    
  }
  
  private func showCameraFeed() {
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    previewLayer.frame = view.frame
  }
  
  private func getCameraFrames() {
    videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
    
    videoDataOutput.alwaysDiscardsLateVideoFrames = true
    // You do not want to process the frames on the Main Thread so we off load to another thread
    videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
    
    captureSession.addOutput(videoDataOutput)
    
    guard let connection = videoDataOutput.connection(with: .video), connection.isVideoOrientationSupported else {
      return
    }
    
    connection.videoOrientation = .portrait
  }

  
  private let handPoseRequest: VNDetectHumanHandPoseRequest = {
    // 1
    let request = VNDetectHumanHandPoseRequest()
    
    // 2
    request.maximumHandCount = 2
    return request
  }()
  
  // 1
  var pointsProcessorHandler: (([CGPoint]) -> Void)?

  func processPoints(_ fingerTips: [CGPoint]) {
    // 2
    let convertedPoints = fingerTips.map {
      previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
    }

    // 3
    pointsProcessorHandler?(convertedPoints)
  }

  


  private func detectFace(image: CVPixelBuffer) {
    let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
      DispatchQueue.main.async {
        if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
          // print("✅ Detected \(results.count) faces!")
          self.handleFaceDetectionResults(observedFaces: results)
        } else {
          // print("❌ No face was detected")
          self.clearDrawings()
        }
      }
    }
    
    let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
    try? imageResultHandler.perform([faceDetectionRequest])
  }

  private func handleFaceDetectionResults(observedFaces: [VNFaceObservation]) {
    clearDrawings()
    
//    print(observedFaces)
    
    // Create the boxes
    let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
      
      let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
    
      
         
      let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
      let faceBoundingBoxShape = CAShapeLayer()
        
      // Set properties of the box shape
      faceBoundingBoxShape.path = faceBoundingBoxPath
      faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
      faceBoundingBoxShape.strokeColor = gameLogicController.isShape ? UIColor.clear.cgColor : UIColor.red.cgColor
      faceBoundingBoxShape.lineWidth = gameLogicController.isShape ? 0 : 3

      return faceBoundingBoxShape
    })
    
    // Add boxes to the view layer and the array
    facesBoundingBoxes.forEach { faceBoundingBox in
      view.layer.addSublayer(faceBoundingBox)
      drawings = facesBoundingBoxes
    }
  }
  
  private func clearDrawings() {
    drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
  }
  
}

extension
CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
      func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
      ) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          debugPrint("Unable to get image from the sample buffer")
          return
        }
        
        detectFace(image: frame)
        
          var fingerTips: [CGPoint] = []
          defer {
            DispatchQueue.main.sync {
              self.processPoints(fingerTips)
            }
          }
    
        // 1
        let handler = VNImageRequestHandler(
          cmSampleBuffer: sampleBuffer,
          orientation: .up,
          options: [:]
        )
    
        do {
          // 2
          try handler.perform([handPoseRequest])
    
          // 3
          guard
            let results = handPoseRequest.results?.prefix(2),
            !results.isEmpty
          else {
            return
          }
          var recognizedPoints: [VNRecognizedPoint] = []
          var sizeScreen: CGRect = UIScreen.main.bounds
          try results.forEach { observation in
            // 1
            let fingers = try observation.recognizedPoints(.all)
            // Tip
            if let thumbTipPoint = fingers[.thumbTip] {
              recognizedPoints.append(thumbTipPoint)
            }
            if let indexTipPoint = fingers[.indexTip] {
              recognizedPoints.append(indexTipPoint)
            }
            if let middleTipPoint = fingers[.middleTip] {
              recognizedPoints.append(middleTipPoint)
            }
            if let ringTipPoint = fingers[.ringTip] {
              recognizedPoints.append(ringTipPoint)
            }
            if let littleTipPoint = fingers[.littleTip] {
              recognizedPoints.append(littleTipPoint)
            }
            // Pip
    
            if let thumbIpPoint = fingers[.thumbIP] {
              recognizedPoints.append(thumbIpPoint)
            }
            if let indexPipPoint = fingers[.indexPIP] {
              recognizedPoints.append(indexPipPoint)
            }
            if let middlePipPoint = fingers[.middlePIP] {
              recognizedPoints.append(middlePipPoint)
            }
            if let ringPipPoint = fingers[.ringPIP] {
              recognizedPoints.append(ringPipPoint)
            }
            if let littlePipPoint = fingers[.littlePIP] {
              recognizedPoints.append(littlePipPoint)
            }
    
    
            // MCP
            if let thumbMpPoint = fingers[.thumbMP] {
              recognizedPoints.append(thumbMpPoint)
            }
            if let indexMCPPoint = fingers[.indexMCP] {
              recognizedPoints.append(indexMCPPoint)
            }
            if let middleMCPPoint = fingers[.middleMCP] {
              recognizedPoints.append(middleMCPPoint)
            }
            if let ringMCPPoint = fingers[.ringMCP] {
              recognizedPoints.append(ringMCPPoint)
            }
            if let littleMCPPoint = fingers[.littleMCP] {
              recognizedPoints.append(littleMCPPoint)
            }
    
            // CMC
            if let thumbDipPoint = fingers[.thumbCMC] {
              recognizedPoints.append(thumbDipPoint)
            }
            if let indexDipPoint = fingers[.indexDIP] {
              recognizedPoints.append(indexDipPoint)
            }
            if let middleDipPoint = fingers[.middleDIP] {
              recognizedPoints.append(middleDipPoint)
            }
            if let ringDipPoint = fingers[.ringDIP] {
              recognizedPoints.append(ringDipPoint)
            }
            if let littleDipPoint = fingers[.littleDIP] {
              recognizedPoints.append(littleDipPoint)
            }
          }
    
          // 3
          fingerTips = recognizedPoints.filter {
            // Ignore low confidence points.
            $0.confidence > 0.9
          }
          .map {
            // 4
            CGPoint(x: $0.location.x, y: 1 - $0.location.y)
          }
    
        } catch {
          // 4
//          cameraFeedSession?.stopRunning()
        }
    
      
  }
}



















