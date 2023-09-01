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

struct ContentView: View {
  @StateObject private var gameLogicController = GameLogicController()
  @State  private  var overlayPoints: [ CGPoint ] = []
  @ViewBuilder
  
  
    
    private func successBadge(number: Int) -> some View {
      
      return Image(systemName: "\(number).circle.fill")
              .resizable()
              .imageScale(.large)
              .foregroundColor(.white)
              .frame(width: 200, height: 200)
              .shadow(radius: 5)
    }
  
  private var viewsArray = RedCircle().drawCircles()
  

  private func show(number: Int) -> some View {
    
//     gameLogicController.didRainStars(count: [round(viewsArray[number].frame.origin.x),round(viewsArray[number].frame.origin.y)])
    
    return  gameLogicController.shouldEvaluateResult && !gameLogicController.isShape ?
    Image(systemName: "circle.fill")
      .resizable()
      .imageScale(.large)
      .foregroundColor(.red)
      .frame(width: 50, height: 50)
      .position(x: viewsArray[number].frame.origin.x,y: viewsArray[number].frame.origin.y) 
    :
    Image(systemName: "circle.fill")
      .resizable()
      .imageScale(.large)
      .foregroundColor(.red)
      .frame(width: 0, height: 0)
      .position(x: 0,y: 0)
  }
  
  private func showCount(number: Int) -> some View {
    
    if gameLogicController.isShape {
      return Image(systemName: "\(number).circle.fill")
        .resizable()
        .imageScale(.large)
        .foregroundColor(.white)
        .frame(width: 70, height: 70)
        .position(x: UIScreen.main.bounds.width/2,y: 50)
    
    }
    gameLogicController.didRainStars(count: [round(viewsArray[number].frame.origin.x),round(viewsArray[number].frame.origin.y)])
    return  Image(systemName: "\(number).circle.fill")
      .resizable()
      .imageScale(.large)
      .foregroundColor(.white)
      .frame(width: 70, height: 70)
      .position(x: UIScreen.main.bounds.width/2,y: 50)
  }

  let viewHeight = UIScreen.main.bounds.size.height
  let viewWidth = UIScreen.main.bounds.size.width
  
  var body: some View {
    ZStack {
      CameraView {
        overlayPoints = $0
        gameLogicController.checkStarsCount([ round($0.first?.x ?? 0)  ,round($0.first?.y ?? 0)])
      }
      showCount(number: gameLogicController.successBadge)
      
//      StarAnimator(makeItRain: $gameLogicController.makeItRain) {_ in
//        let number = gameLogicController.successBadge
//          gameLogicController.didRainStars(count: [round(viewsArray[number].frame.origin.x),
//                                                   round(viewsArray[number].frame.origin.y)
//                                                  ])
//        
//      }
      

    }
    .onAppear {
      gameLogicController.changeCountCircle(viewsArray.count)
    }
    .overlay(show(number: gameLogicController.successBadge))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
