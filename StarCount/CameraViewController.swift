import UIKit
import SwiftUI
import AVFoundation
import Vision

 class CameraViewController: UIViewController {
  
  private var drawings: [CAShapeLayer] = []


  
//  private let videoDataOutput = AVCaptureVideoDataOutput()
  private let videoDataOutput = AVCaptureVideoDataOutput()
  
  private let captureSession = AVCaptureSession()
  
    
  /// Using `lazy` keyword because the `captureSession` needs to be loaded before we can use the preview layer.
  private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addCameraInput()
    showCameraFeed()
    
    getCameraFrames()
    captureSession.startRunning()
  
    
    let value = UIInterfaceOrientation.landscapeLeft.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")

  }
  
  override var shouldAutorotate: Bool {
      return true
  }
  

//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    previewLayer.frame = view.frame
//  }
  
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
    
    if #available(iOS 17.0, *) {
      previewLayer.connection?.videoRotationAngle = 180
    } else {
      // Fallback on earlier versions
      previewLayer.connection?.videoOrientation = .landscapeRight
    }
  }
  
  private func getCameraFrames() {
    videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
    
    videoDataOutput.alwaysDiscardsLateVideoFrames = true
    // You do not want to process the frames on the Main Thread so we off load to another thread
    videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "CameraFeedOutput", qos: .userInteractive))
    
    captureSession.addOutput(videoDataOutput)
    
  }

  
  private let handPoseRequest: VNDetectHumanHandPoseRequest = {
    // 1
    let request = VNDetectHumanHandPoseRequest()
    
    // 2
    request.maximumHandCount = 2
    return request
  }()
  
  // 1
  var pointsProcessorHandler: (([[CGPoint]]) -> Void)?
  
  var isShare:Bool?
  
  var pointsProcessorFace: (([Path]) -> Void)?
   
   var pointsProcessorBody: (([CGPoint]) -> Void)?
  

  func processPoints(_ fingerTips: [[CGPoint]]) {
    // 2
    let convertedPointsOne = fingerTips[0].map {
      previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
    }

    // 3
    
    
    let convertedPointsTwo = fingerTips[1].map {
      previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
    }

    // 3
    pointsProcessorHandler?([convertedPointsOne,convertedPointsTwo])
  
  }
  
  func processFacePoints(_ faceTips: [Path]) {
    pointsProcessorFace?(faceTips)
  }


  


  private func detectFace(image: CVPixelBuffer) {
    let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
      DispatchQueue.main.async {
        if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
          // print("✅ Detected \(results.count) faces!")
          self.handleFaceDetectionResults(observedFaces: results)
        } else {
          let emptyPath = Path() {data in
            data.move(to: CGPoint(x: 0, y: 0))
          }
          self.processFacePoints([emptyPath])
          // print("❌ No face was detected")
          self.clearDrawings()
        }
      }
    }
    
    let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .downMirrored, options: [:])
    try? imageResultHandler.perform([faceDetectionRequest])
  }
  
   

   
  private func handleFaceDetectionResults(observedFaces: [VNFaceObservation]) {
    clearDrawings()
    

    // Create the boxes
    let facesBoundingBoxes: [Path] = observedFaces.map({ (observedFace: VNFaceObservation) in
      
      let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
    
      let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
      
      return Path(faceBoundingBoxPath)
    })
    processFacePoints(facesBoundingBoxes)
   
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
        
        
          var fingerTips: [[CGPoint]] = [[],[]]
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
          var recognizedPoints: [[VNRecognizedPoint]] = [[],[]]
          
//          if #available(iOS 15.0, *) {
//            print(results.first?.chirality == VNChirality.left)
//          } else {
//            // Fallback on earlier versions
//          }
          for (index,observation) in results.enumerated() {
            let fingers = try results[index].recognizedPoints(.all)
            // Tip
            if let thumbTipPoint = fingers[.thumbTip] {
              recognizedPoints[index].append(thumbTipPoint)
            }
            if let indexTipPoint = fingers[.indexTip] {
              recognizedPoints[index].append(indexTipPoint)
            }
            if let middleTipPoint = fingers[.middleTip] {
              recognizedPoints[index].append(middleTipPoint)
            }
            if let ringTipPoint = fingers[.ringTip] {
              recognizedPoints[index].append(ringTipPoint)
            }
            if let littleTipPoint = fingers[.littleTip] {
              recognizedPoints[index].append(littleTipPoint)
            }
            // Pip
    
            if let thumbIpPoint = fingers[.thumbIP] {
              recognizedPoints[index].append(thumbIpPoint)
            }
            if let indexPipPoint = fingers[.indexPIP] {
              recognizedPoints[index].append(indexPipPoint)
            }
            if let middlePipPoint = fingers[.middlePIP] {
              recognizedPoints[index].append(middlePipPoint)
            }
            if let ringPipPoint = fingers[.ringPIP] {
              recognizedPoints[index].append(ringPipPoint)
            }
            if let littlePipPoint = fingers[.littlePIP] {
              recognizedPoints[index].append(littlePipPoint)
            }
    
    
            // MCP
            if let thumbMpPoint = fingers[.thumbMP] {
              recognizedPoints[index].append(thumbMpPoint)
            }
            if let indexMCPPoint = fingers[.indexMCP] {
              recognizedPoints[index].append(indexMCPPoint)
            }
            if let middleMCPPoint = fingers[.middleMCP] {
              recognizedPoints[index].append(middleMCPPoint)
            }
            if let ringMCPPoint = fingers[.ringMCP] {
              recognizedPoints[index].append(ringMCPPoint)
            }
            if let littleMCPPoint = fingers[.littleMCP] {
              recognizedPoints[index].append(littleMCPPoint)
            }
    
            // CMC
            if let thumbDipPoint = fingers[.thumbCMC] {
              recognizedPoints[index].append(thumbDipPoint)
            }
            if let indexDipPoint = fingers[.indexDIP] {
              recognizedPoints[index].append(indexDipPoint)
            }
            if let middleDipPoint = fingers[.middleDIP] {
              recognizedPoints[index].append(middleDipPoint)
            }
            if let ringDipPoint = fingers[.ringDIP] {
              recognizedPoints[index].append(ringDipPoint)
            }
            if let littleDipPoint = fingers[.littleDIP] {
              recognizedPoints[index].append(littleDipPoint)
            }
          }
//          try results.forEach { observation in
//            // 1
//
//          }
    
          // 3
          fingerTips[0] = recognizedPoints[0].filter {
            // Ignore low confidence points.
            $0.confidence > 0.9
          }
          .map {
            // 4
            CGPoint(x: $0.location.x, y: 1 - $0.location.y)
          }
          
          fingerTips[1] = recognizedPoints[1].filter {
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



















