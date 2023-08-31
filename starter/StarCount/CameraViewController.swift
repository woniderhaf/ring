import UIKit
import AVFoundation
import Vision

final class CameraViewController: UIViewController {
  
  private var cameraView: CameraPreview { view as! CameraPreview }
  
  private let videoDataOutputQueue = DispatchQueue(
    label: "CameraFeedOutput",
    qos: .userInteractive
  )
  private var cameraFeedSession: AVCaptureSession?

  // 1
  override func loadView() {
    view = CameraPreview()

    //    self.cameraView.previewLayer.frame = self.view.bounds
    
  }
  
  private var gameLogicController = GameLogicController()
  

  
  override func viewDidLoad() {
    super.viewDidLoad()
    

  
    
//    let value = UIInterfaceOrientation.landscapeLeft.rawValue
//    UIDevice.current.setValue(value, forKey: "orientation")
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscapeLeft
}
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .landscapeLeft
  }

override var shouldAutorotate: Bool {
    return true
}

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    do {
      if cameraFeedSession == nil {
        try setupAVSession()
        cameraView.previewLayer.session = cameraFeedSession
        cameraView.previewLayer.videoGravity = .resizeAspectFill
      }
      cameraFeedSession?.startRunning()
    } catch {
      print(error.localizedDescription)
    }
  }

  // 5
  override func viewWillDisappear(_ animated: Bool) {
    cameraFeedSession?.stopRunning()
    super.viewWillDisappear(animated)
  }

  func setupAVSession() throws {
    // 1
    guard let videoDevice = AVCaptureDevice.default(
      .builtInWideAngleCamera,
      for: .video,
      position: .front)
    else {
      throw AppError.captureSessionSetup(
        reason: "Could not find a front facing camera."
      )
    }
    

    // 2
    guard
      let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
    else {
      throw AppError.captureSessionSetup(
        reason: "Could not create video device input."
      )
    }

    // 3
    let session = AVCaptureSession()
    session.beginConfiguration()
    session.sessionPreset = AVCaptureSession.Preset.high

    // 4
    guard session.canAddInput(deviceInput) else {
      throw AppError.captureSessionSetup(
        reason: "Could not add video device input to the session"
      )
    }
    session.addInput(deviceInput)

    // 5
    let dataOutput = AVCaptureVideoDataOutput()
    if session.canAddOutput(dataOutput) {
      session.addOutput(dataOutput)
      dataOutput.alwaysDiscardsLateVideoFrames = true
      dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
    } else {
      throw AppError.captureSessionSetup(
        reason: "Could not add video data output to the session"
      )
    }
    
    // 6
    session.commitConfiguration()
    cameraFeedSession = session
  }


//  private let videoDataOutputQueue = DispatchQueue(
//    label: "CameraFeedOutput",
//    qos: .userInteractive
//  )

  

  
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
      cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
    }

    // 3
    pointsProcessorHandler?(convertedPoints)
  }

  


  

  
 
  
}

extension
CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
      func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
      ) {
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
    //        print("fingers x: \(( -(fingers[.middleDIP]?.location.y ?? 0) ?? 0) * sizeScreen.width + sizeScreen.width),fingers y: \( ( fingers[.middleDIP]?.location.x ?? 0) * sizeScreen.height) ")
    
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
          cameraFeedSession?.stopRunning()
        }
    
      
  }
}



















