import SwiftUI
import Vision
import AVFoundation

// 1
struct CameraView: UIViewControllerRepresentable {
  
  
  var pointsProcessorHandler: (([[ CGPoint ]]) -> Void )?
  var pointsProcessorFace: (([Path]) -> Void )?
  var pointsProcessorBody: (([CGPoint]) -> Void )?
  
  // 2
 
  
  func makeUIViewController(context: Context) -> CameraViewController {
    let cvc = CameraViewController()
    
    cvc.pointsProcessorHandler = pointsProcessorHandler
    cvc.pointsProcessorFace = pointsProcessorFace
    cvc.pointsProcessorBody = pointsProcessorBody
    return cvc
  }

  // 3
  func updateUIViewController(
    _ uiViewController: CameraViewController,
    
    context: Context
  ) {
  }
}
