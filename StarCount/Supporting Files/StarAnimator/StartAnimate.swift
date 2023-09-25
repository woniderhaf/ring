/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct StartAnimate: UIViewRepresentable {
  
  final class Coordinator: NSObject, StartAnimateDelegate {
    func updateSpeed(speed: Double) {
      parent.updateSpeed(speed)
    }
    
    
    var isFinish: Bool
    
    func updateTimerCount(count: Int) {
      parent.updateTimerCount(count)
    }
    
    var parent: StartAnimate
    
 

    init(_ parent: StartAnimate) {
      self.parent = parent
      self.isFinish  = parent.isFinish
      
    }

    func didStartRaining(count: Int) {
      parent.isStart = false
      parent.numberOfStarsHandler(count)
    }
    
    func start() {
      parent.start()
    }
    
    func setIsRender() {
      parent.setIsRender()
    }
    
    
  }

  @Binding var isStart: Bool
  
  @Binding var isRender: Bool
  
  @Binding var isAnimation: Bool
  
  @Binding var isFinish: Bool
  
  @Binding var glasses: Int
  
  var updateSpeed:(_ speed:Double) -> Void
  
  var numberOfStarsHandler: (Int) -> Void
  
  var updateTimerCount: (_ count:Int) -> Void
  
  var setIsRender: () -> Void
  
  var start: () -> Void

  func makeUIView(context: Context) -> StarAnimatorView {
    let view = StarAnimatorView()
    view.delegate = context.coordinator
    
    return view
    
  }

  func updateUIView(_ uiView: StarAnimatorView, context: Context) {
    if !isStart && !isRender {
      print("START RAIN")
      uiView.rain(complection: setIsRender)
    }
    if isFinish {
      
      uiView.finish(glasses:glasses)
    }

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
