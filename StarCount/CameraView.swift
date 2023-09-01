import SwiftUI
import AVFoundation

// 1
struct CameraView: UIViewControllerRepresentable {
  
  var pointsProcessorHandler: (([ CGPoint ]) -> Void )?

  // 2
  func makeUIViewController(context: Context) -> CameraViewController {
    let cvc = CameraViewController()
  
    
    cvc.pointsProcessorHandler = pointsProcessorHandler
    return cvc
  }

  // 3
  func updateUIViewController(
    _ uiViewController: CameraViewController,
    context: Context
  ) {
  }
}
