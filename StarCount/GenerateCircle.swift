import UIKit


class RedCircle {
  func drawCircles() -> [UIView] {
    var number = 1
    var maxCount = 5
    var viewsArray: [UIView] = []
    
    //1. Ширина и высота экрана
    let viewHeight = UIScreen.main.bounds.size.height
    let viewWidth = UIScreen.main.bounds.size.width
    
    while number <= maxCount {
      //2. Радиус круга
      let rectSideSize: CGFloat = 50
      
      //3. Два рандомных числа
      let randomNumberOne = CGFloat.random(in: viewWidth*0.2...viewWidth*0.8)//CGFloat(arc4random_uniform(40))
      let randomNumberTwo = CGFloat.random(in: 100...viewHeight*0.3)//CGFloat(arc4random_uniform(20))
//      print("randomNumberOne: \(randomNumberOne), randomNumberTwo: \(randomNumberTwo)")
      //4. Координаты и размеры круга
      let rect = CGRect(x:  randomNumberOne,
                        y:  randomNumberTwo,
                        width: rectSideSize,
                        height: rectSideSize)
      
      //5. Смотрим пересечение
      let newView = UIView(frame: rect)
//      guard (viewsArray.filter { $0.isCrossing(newView) }).isEmpty else { print(false); continue }
      
      //6. Задаём цвет и делаем обрезку
      newView.layer.cornerRadius = rectSideSize/2
      newView.layer.masksToBounds = true
      newView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
      
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
