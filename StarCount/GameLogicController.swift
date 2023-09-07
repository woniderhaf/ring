

import Combine
import Foundation
import UIKit
import SwiftUI

final class GameLogicController: ObservableObject {
  
 var isStart = true

  private var goalCount = 0
  
  
  //  если true  то показываем контур головы
  var isShape:Bool = false
  
  var countCircles = 0
  var activeCircleIndex = 0
  
  private var coordinateCircles: [CGFloat] = [0,0]
  
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
  
  
  var sideCount:Int = 0
  // if sideCount = 0 то новые круги,иначе вычисляем

  // 2
  @Published var makeItRain = false

  // 3
  @Published private(set) var successBadge: Int = 0

  // 4
  var shouldEvaluateResult = true
  
  
  var startEvade = false
  
//  var viewsArray = RedCircle().drawCircles(maxCount: Int.random(in: 1...6))
  var viewsArray = RedCircle().drawCircles(maxCount: 1)
  
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
    
    if(!self.isStart) {
      self.didRainStars(count: [viewWidth-90,200])
    }
  }
  let viewHeight = UIScreen.main.bounds.size.height
  let viewWidth = UIScreen.main.bounds.size.width
  // 6
  func didRainStars(count: [CGFloat]) {
    coordinateCircles = count
  }
  
  func changeCountCircle(_ count: Int) {
    countCircles = count
  }
  
  func setActiveIndexCirlce() {
    activeCircleIndex += 1
  }
  func resetActiveIndexCircle() {
    activeCircleIndex = 0
  }

  
  func checkStarsCount(_ count: [CGFloat]) {
    

    let x = count[0]
    let y = count[1]
    
    
    if !shouldEvaluateResult || countCircles == 0  {
      return
    }
    
    
    if  x >= (coordinateCircles[0] - 50)
        && x <= (coordinateCircles[0] + 50)
        && y >= (coordinateCircles[1] - 50)
        && y <= (coordinateCircles[1] + 50) {
      
      if !self.isStart {
        
        self.isStart = true
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

  
  

}
