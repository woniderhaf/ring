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

import Combine
import Foundation

final class GameLogicController: ObservableObject {
  // 1
  private var goalCount = 0
  
  private var coordinateCircles: [CGFloat] = [0,0]

  // 2
  @Published var makeItRain = false

  // 3
  @Published private(set) var successBadge: Int = 0

  // 4
  var shouldEvaluateResult = true

  // 5
  func start() {
    makeItRain = true
  }

  // 6
  func didRainStars(count: [CGFloat]) {
    print("didRainStars count: \(count)")
    coordinateCircles = count
  }

  // 7
  func checkStarsCount(_ count: [CGFloat]) {
    if !shouldEvaluateResult {
      return
    }
    if count[0] >= (coordinateCircles[0] - 50)
        && count[0] <= (coordinateCircles[0] + 50)
        && count[1] >= (coordinateCircles[1] - 50)
        && count[1] <= (coordinateCircles[1] + 50) {
      
      goalCount += 1
      shouldEvaluateResult = false
      successBadge = goalCount

      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.makeItRain = true
        self.shouldEvaluateResult = true
      }
    }
  }

}
