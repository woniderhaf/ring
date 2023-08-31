// 1
import UIKit
import AVFoundation

final class CameraPreview: UIView {
  // 2
  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
    
  }
  
  // 3
  var previewLayer: AVCaptureVideoPreviewLayer {
    layer as! AVCaptureVideoPreviewLayer
  }
}
