import UIKit
import SwiftUI


class RedCircle {
  
  func drawCircles(maxCount: Int) -> [UIView] {
    var number = 1
//    var maxCount = 5
    var viewsArray: [UIView] = []
    
    //1. Ширина и высота экрана
    let viewHeight = UIScreen.main.bounds.size.height
    let viewWidth = UIScreen.main.bounds.size.width
    
    while number <= maxCount {
      //2. Радиус круга
      let rectSideSize: CGFloat = 50
      
      //3. Два рандомных числа
      let x = CGFloat.random(in: viewWidth*0.2...viewWidth*0.8)//CGFloat(arc4random_uniform(40))
      let y = CGFloat.random(in: 100...viewHeight*0.3)//CGFloat(arc4random_uniform(20))

      //4. Координаты и размеры круга
      let rect = CGRect(x:  x,
                        y:  y,
                        width: rectSideSize,
                        height: rectSideSize)
      
      //5. Смотрим пересечение
      let newView = UIView(frame: rect)

      
      //6. Задаём цвет и делаем обрезку
      newView.layer.cornerRadius = rectSideSize/2
      newView.layer.masksToBounds = true
      
      
      //7. Добавляем в массив
      viewsArray.append(newView)
      number += 1
      
    }
    return viewsArray
  }
}

extension UIView {
func isCrossing(_ view: UIView) -> Bool {
    let firstParams = (midX: Float(self.frame.midX), midY: Float(self.frame.midY), radius: Float(self.frame.width/2))
    let secondParams = (midX: Float(view.frame.midX), midY: Float(view.frame.midY), radius: Float(view.frame.width/2))
    let distance = (firstParams.midX - secondParams.midX, firstParams.midY - secondParams.midY)
    let hypotenuse = sqrtf(powf(distance.0, 2) + powf(distance.1, 2))
    return hypotenuse - (firstParams.radius + secondParams.radius) <= 0 ? true : false
    }
}
