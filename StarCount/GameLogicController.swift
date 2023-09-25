

import Combine
import Foundation
import UIKit
import SwiftUI

final class GameLogicController: ObservableObject {
  let viewHeight = UIScreen.main.bounds.size.height
  let viewWidth = UIScreen.main.bounds.size.width
  
  var isStart = false
  var isFinish = false
  var isAnimation = false

  private var goalCount = 0
  
  
  //  если true  то показываем контур головы
  var isShape:Bool = false
  
  var isCheckPose = false
  
  
  var countCircles = 0
  var activeCircleIndex = 0
  
  private var coordinateCircles: [CGFloat] = [500,500] // start
  
  // квадрат головы
  var positionFace: CGPoint?
  
  // сторона (лево false / право true)
  var side: Bool = Bool.random()
  
//  var pointsFace: [CGF]
  
  // метки
  var evadePoints: [CGPoint] = []
  
  // если голова попала на метку, она попадает сюда, и меняет свой цвет
  var successPoints: [Int] = []
  var failePoints: [Int] = []
  
  // if sideCount = 0 то новые круги,иначе вычисляем
  var sideCount:Int = 0
  
  
  var timer:Timer = Timer()
  var timeCount:Int = 0
  @Published var timeString = ""
  
  

  // 2
  @Published var makeItRain = false

  // 3
  @Published var successBadge: Int = 0
  
  @Published var speed: Double = 1.5

  // 4
  var shouldEvaluateResult = true
  
  var startEvade = false
  
  var isRender = false
  
  var viewsArray = RedCircle().drawCircles(maxCount: Int.random(in: 1...6))
//  var viewsArray = RedCircle().drawCircles(maxCount: 50)
  
  func updateViewsArray(count:Int) {
    viewsArray = RedCircle().drawCircles(maxCount: count)
    changeCountCircle(count)
    resetActiveIndexCircle()
    self.evadePoints = []
    self.successPoints = []
    self.failePoints = []
  }
  
  var buttonColor = Color.white
  // 5
  func start() {
    makeItRain = true
  }
  
  
  func play() {
    print("start = true")
    self.isStart = true
    self.successBadge = 0
    self.goalCount = 0
    self.isFinish = false
    didRainStars(count: [round(viewsArray[activeCircleIndex].frame.origin.x),round(viewsArray[activeCircleIndex].frame.origin.y)])
    startTimer()
  }
  
  func updateSpeed(speed:Double) {
    print("update speed")
    self.speed = speed
  }
  
  func setIsRender() {
    print("Isrender = true")
    self.isRender = true
  }

  // 6
  func didRainStars(count: [CGFloat]) {
    
    coordinateCircles = count
  }
  
  @objc func countdec() {
    timeCount -= 1
    let time = secondsToMinutesSeconds(seconds: timeCount)
    timeString = makeTimeString(minutes: time.0, seconds: time.1)
    if (timeCount == 0) {
      stop()
    }
  }
  
  func updateTimeCount(count:Int) {
    timeCount = count
  }
  
  func secondsToMinutesSeconds(seconds:Int) -> (Int,Int) {
    return ( ((seconds % 3600) / 60), ((seconds % 3600) % 60) )
  }
  
  func makeTimeString(minutes:Int,seconds:Int) -> String {
    var timeString = ""
    timeString += String(format: "%02d", minutes)
    timeString += " : "
    timeString += String(format: "%02d", seconds)
    return timeString
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(countdec) , userInfo: nil, repeats: true)
  }
  
  func stop() {
    print("STOP!")
    timer.invalidate()
    timeString = ""
    isStart = false
    isFinish = true
  }
  
  func changeCountCircle(_ count: Int) {
    countCircles = count
  }
  
  func setActiveIndexCirlce() {
    print("setActiveIndexCirlce")
    activeCircleIndex += 1
    if (activeCircleIndex + 1 < viewsArray.count) { 
      didRainStars(count: [round(viewsArray[activeCircleIndex].frame.origin.x),round(viewsArray[activeCircleIndex].frame.origin.y)])
    }
  }
  func resetActiveIndexCircle() {
    activeCircleIndex = 0
  }

  //checkStarsCount
  let radius = 50.0
  func checkStarsCount(_ points: [[CGPoint]]) {

    var res = false
    points.forEach {
      $0.forEach{
        if ($0.x - coordinateCircles[0] < radius && $0.x - coordinateCircles[0] > 0 && $0.y - coordinateCircles[1]  > 0 && $0.y - coordinateCircles[1] < radius) {
          res = true
        }
      }
    }
//    
//    var arrY0:[CGFloat] = points[0].map { $0.y }
//    var arrX0:[CGFloat] = points[0].map { $0.x }
//
//    var arrY1:[CGFloat] = points[1].map { $0.y }
//    var arrX1:[CGFloat] = points[1].map { $0.x }
//    
//    
//    var arrY:[CGFloat] = arrY0 + arrY1
//    var arrX:[CGFloat] = arrX0 + arrX1
//    
//    let Xmin:CGFloat = arrX.min() ?? 0
//    let Xmax:CGFloat = arrX.max() ?? 0
//    let Ymin:CGFloat = arrY.min() ?? 0
//    let Ymax:CGFloat = arrY.max() ?? 0

  
    
    if !shouldEvaluateResult || countCircles == 0  {
      return
    }
    
    
//    if  Xmin < coordinateCircles[0] && Xmax > coordinateCircles[0] && Ymin < coordinateCircles[1] && Ymax > coordinateCircles[1]
    if res
    {
      
      if !self.isStart {
        self.isAnimation = true
      } else {
        
        goalCount += 1
        
        if countCircles == 0 {
          
          print("count circles == 0")
          
        } else if countCircles == 1 {
          
          print("is share = true")
          isShape = true
          self.randomSideCount()
          resetActiveIndexCircle()
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.startEvade = true
          }
          
        }
        
        changeCountCircle(countCircles - 1)
        setActiveIndexCirlce()
        shouldEvaluateResult = false
        successBadge = goalCount
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.makeItRain = true
          self.shouldEvaluateResult = true
        }
      }
     
    } else if !self.isStart {
      self.isAnimation = false
    }
  }
  
  func changePositionFace(path: Path) {
    self.startEvade = false
    self.positionFace = path.currentPoint
    
    evade()
  }
  
  func changeSide() {
    print("<<<--- change Side --->>>")
    if self.sideCount > 0 {
      self.shouldEvaluateResult = false
      self.successPoints = []
      self.evadePoints = []
      self.failePoints = []
      randomSide()
      evade()
      self.sideCount -= 1
    }
    else {
      self.setIsShape()
      self.updateViewsArray(count: Int.random(in: 1...6))
    }
  }
  
  func randomSideCount() {
    self.sideCount = Int.random(in: 1...4)
  }
  
  func randomSide() {
    let newSide = Bool.random()
    print(newSide)
    self.side = newSide
  }
  
  func setIsShape() {
    self.isShape = !self.isShape
  }
  
  func evade() {
    //center
    let startPoint = self.positionFace ?? CGPoint(x: 0, y: 0)
    if self.side {
      let fitstPoint =  CGPoint(x: startPoint.x  + 120, y: startPoint.y + 30)
      let TwoPoint =  CGPoint(x: startPoint.x + 135, y: startPoint.y + 60)
      let ThreePoint =  CGPoint(x: startPoint.x + 150, y: startPoint.y + 90)
      let ThrowPoint =  CGPoint(x: startPoint.x + 165, y: startPoint.y + 120)
      self.evadePoints = [fitstPoint,TwoPoint,ThreePoint,ThrowPoint]
    } else {
      let fitstPoint =  CGPoint(x: startPoint.x  - 20, y: startPoint.y + 30)
      let TwoPoint =  CGPoint(x: startPoint.x - 35, y: startPoint.y + 60)
      let ThreePoint =  CGPoint(x: startPoint.x - 50, y: startPoint.y + 90)
      let ThrowPoint =  CGPoint(x: startPoint.x - 65, y: startPoint.y + 120)
      self.evadePoints = [fitstPoint,TwoPoint,ThreePoint,ThrowPoint]
    }
    self.shouldEvaluateResult = true

  }
  
  // добовление очка
  func successEvadePoint(point:Int) {
    
    if !self.successPoints.contains(point) {
      
      self.successPoints.append(point)
      self.goalCount += 1
      self.successBadge = goalCount
      
      if point > 0 && self.successPoints.contains(point - 1) {
        self.failePoints.append(point-1)
      }
      
    }
    
  }

  func passCircle() {
    if countCircles == 1 {
      isShape = true
      self.randomSideCount()
      resetActiveIndexCircle()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.startEvade = true
      }
      
    }
    changeCountCircle(countCircles - 1)
    setActiveIndexCirlce()
    
  }
  
  
//end
}
