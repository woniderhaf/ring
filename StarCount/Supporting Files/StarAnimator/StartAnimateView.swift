
import UIKit
import SwiftUI

protocol StartAnimateDelegate: class {
  func didStartRaining(count: Int)
  func start()
  func updateTimerCount(count:Int)
}


final class StarAnimatorView: UIView {
  
  
  var speed:String?
  var time: Int?
  
  

  
  var step: Int = 1 // 1 - speed / 2 - time / 3 - start
  
  // выбранные настройки
  var activeSpeed: String?
  var activeTime: String?
    
  private enum Constants {
    static let duration: TimeInterval = 0.7
    static let delay: TimeInterval = 0.2
    static let backgroundAlpha: Double = 0.7
  }
  
  private enum Buttons {
    //speed
    static let slow: String  = "Медленная"
    static let fast: String  = "Быстрая"
    static let dinamic: String  = "Динамическая"
    // time
    static let short: String  = "1 минута"
    static let average: String  = "2 минуты"
    static let long: String  = "3 минуты"
  }


  weak var delegate: StartAnimateDelegate?

  
  // UI
  let viewSpeed = UIView()
  let viewTime = UIView()
  let viewStart = UIView()
  let viewBorder = UIView()
  
  @objc func animationButtonDown(sender: UIButton) {
    sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
  }
 
  @objc func animationButtonUp(sender: UIButton) {
    
    sender.transform = CGAffineTransform(scaleX: 1, y: 1)
    self.speed = sender.titleLabel?.text
   
    
    // анимация ичезновения блока скорости
    UIView.animate(withDuration: Constants.duration) {
//      sender.backgroundColor = .white
      self.viewSpeed.alpha = 0
      self.viewSpeed.transform = CGAffineTransform(translationX: -100, y: 0)
      // добавление блока времени
      self.addSubview(self.viewTime)
    }
    // анимация появления блока времени
    UIView.animate(withDuration: Constants.duration, delay:Constants.delay) {
      self.viewTime.alpha = 1
      self.viewTime.transform = CGAffineTransform(scaleX: 1, y: 1)
      self.step = 2
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.duration) {

      self.viewSpeed.removeFromSuperview()
     
    }
  }
  

  
  func labelCount(count:Int) -> UILabel {
    
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    
    let number = UILabel()
    number.text = String(count)
    number.textColor = .white
    number.textAlignment = .center
    number.layer.frame = CGRect(x: width/2 - 100, y: height/2 - 100,width:200,height:200)
    number.font = UIFont.systemFont(ofSize: 55, weight: .bold)
    number.transform = CGAffineTransform(scaleX: 0, y: 0)
    number.alpha = 0
    return number
  }
 
  func showCount() -> UIView {
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    
    let viewNumber = UIView()
    viewNumber.layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    return viewNumber
  }
  
  func rootNumber(count:Int) {
//    print("count: \(count)")
    let view = self.showCount()
    let label = labelCount(count: count)
    view.addSubview(label)

    self.addSubview(view)
    
    UIView.animate(withDuration: 3) {
      let scale = 4.0
      label.alpha = 1
      label.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    UIView.animate(withDuration: 2,delay: 2) {
      label.alpha = 0
    }
  }
  



  func rain(complection: () -> Void) {
    

    if frame.size.width == 0 {
      return
    }
    
    
    var speed = blockSpeed()
    var time = blockTime()
    
    
    addSubview(speed)
    UIView.animate(withDuration: Constants.duration) {
      self.viewSpeed.alpha = 1
      self.viewSpeed.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
   complection()
  }
  
  func clear() {
    print("clear")
    removeFromSuperview()
  }
  
  @objc func buttonClicked(sender:UIButton) {
    print("click")
    self.delegate?.start()
    clear()
  }
  
  
  func blockSpeed() -> UIView {
    
    viewSpeed.layer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 200, y: UIScreen.main.bounds.height/2 - 150, width: 400, height: 300)
    viewSpeed.layer.cornerRadius = 50
    viewSpeed.backgroundColor = .white.withAlphaComponent(Constants.backgroundAlpha)
    
    
    viewSpeed.addSubview(Button(title: Buttons.slow,key: 1,parent: viewSpeed,action: #selector(animationButtonUp)))
    viewSpeed.addSubview(Button(title: Buttons.fast,key: 2,parent: viewSpeed,action: #selector(animationButtonUp)))
    viewSpeed.addSubview(Button(title: Buttons.dinamic,key: 3,parent: viewSpeed,action: #selector(animationButtonUp)))
    viewSpeed.addSubview(Title(text: "Скорость",parent: viewSpeed))
    
    viewSpeed.alpha = 0
    viewSpeed.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    
    return viewSpeed
  }
  
  func blockTime() -> UIView {
    
    viewTime.layer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 200, y: UIScreen.main.bounds.height/2 - 150, width: 400, height: 300)
    viewTime.layer.cornerRadius = 50
    viewTime.alpha = 0
    viewTime.backgroundColor = .white.withAlphaComponent(Constants.backgroundAlpha)
    
    viewTime.addSubview(Button(title: Buttons.short,key: 1,parent: viewTime,action: #selector(SelectedTime)))
    viewTime.addSubview(Button(title: Buttons.average,key: 2,parent: viewTime,action: #selector(SelectedTime)))
    viewTime.addSubview(Button(title: Buttons.long,key: 3,parent: viewTime,action: #selector(SelectedTime)))
    viewTime.addSubview(Title(text: "Время",parent: viewTime))
    viewTime.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    viewTime.addSubview(BackButton(parent: viewTime))
    
    return viewTime
  }
  
  func blockStart() -> UIView {
    

    
    viewStart.layer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 200, y: UIScreen.main.bounds.height/2 - 150, width: 400, height: 300)
    viewStart.layer.cornerRadius = 50
    viewStart.alpha = 0
    viewStart.backgroundColor = .white.withAlphaComponent(Constants.backgroundAlpha)
    viewStart.addSubview(Title(text: "Можем начинать",parent: viewStart))
    
    viewStart.addSubview(Text(text: "Скорость: \(self.speed!)",
                              frame: CGRect(x: 20, y: 80, width: 300, height: 30),
                              font: .systemFont(ofSize: 20),
                              color: .black,
                              textAlignment: .left
                             ))

    viewStart.addSubview(Text(text: "Время: \(self.time!)",
                              frame: CGRect(x: 20, y: 120, width: 300, height: 30),
                              font: .systemFont(ofSize: 20),
                              color: .black,
                              textAlignment: .left
                             ))
    
    viewStart.addSubview(Button(title: "Старт",key: 3,parent: viewStart,action: #selector(Start)))
    viewStart.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    return viewStart
  }

  let blurEffectViewLeft = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.prominent))
  let blurEffectViewRight = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.prominent))
  
  func blockBorder() -> UIView {
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    
//    viewBorder.ef
    viewBorder.layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
//    viewBorder.backgroundColor = .white.withAlphaComponent(Constants.backgroundAlpha)
    
    
    blurEffectViewLeft.frame = CGRect(x: width/2, y: 0, width: width/2, height: height)
    blurEffectViewLeft.autoresizingMask = [.flexibleWidth,.flexibleHeight]

    

    blurEffectViewRight.frame = CGRect(x: 0, y: 0, width: width/2, height: height)
    blurEffectViewRight.autoresizingMask = [.flexibleWidth,.flexibleHeight]

    
    viewBorder.addSubview(blurEffectViewLeft)
    viewBorder.addSubview(blurEffectViewRight)
    return viewBorder
  }

  
  func Button(title:String,key:Int,parent:UIView, action: Selector) -> UIButton {
    let button = UIButton()
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor =  .gray
    button.layer.cornerRadius = 25
    button.layer.frame = CGRect(x: 30, y: 70 * key, width: Int(parent.frame.width) - 60, height: 60)
    button.addTarget(self, action: #selector(animationButtonDown), for: .touchDown)
    button.addTarget(self, action: action, for: [.touchUpOutside, .touchUpInside])
    return button
  }

  func Title(text:String,parent:UIView) -> UILabel {
    let title = UILabel()
    title.text = text
    title.layer.frame = CGRect(x: 0, y: 20,width:Int(parent.frame.width),height:30)
    title.textAlignment = .center
    title.textColor = .black
    title.font = UIFont.systemFont(ofSize: 23, weight: .bold)
    
    return title
  }
  
  func Text(text:String,frame: CGRect,font:UIFont,color:UIColor,textAlignment: NSTextAlignment) -> UILabel {
    let title = UILabel()
    title.text = text
    title.layer.frame = frame
    title.textAlignment = textAlignment
    title.textColor = color
    title.font = font
    
    return title
  }
  
  func BackButton(parent:UIView) -> UIButton {
    
    var button = UIButton()
    let configuration = UIImage.SymbolConfiguration(pointSize: 50)
    var image = UIImage(systemName: "arrowshape.backward.circle",withConfiguration: configuration)
    
    button.tintColor = .gray
    button.setImage(image, for: .normal)
    button.backgroundColor = .clear
    button.layer.frame = CGRect(x: 30, y: 10, width: 50, height: 50)
    button.addTarget(self, action: #selector(BackAction), for: .touchDown)
    return button
  }
  
  @objc func BackAction(sender:UIButton) {
    
    self.viewSpeed.alpha = 0
    self.viewSpeed.transform = CGAffineTransform(translationX: -100, y: 0)
    addSubview(self.viewSpeed)
    // анимация ичезновения блока времени
    UIView.animate(withDuration: Constants.duration) {
      
      self.viewTime.alpha = 0
      self.viewTime.transform = CGAffineTransform(scaleX: 0.8,y: 0.8)
      
    }
    // анимация появления блока скорости ( возвращение )
    UIView.animate(withDuration: Constants.duration, delay:Constants.delay) {
      self.viewSpeed.alpha = 1
      self.viewSpeed.transform = CGAffineTransform(translationX: 0,y: 0)
      
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.duration) {
      print("delete view time")
      self.viewTime.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      self.viewTime.removeFromSuperview()
      
    }
  }
  
  @objc func SelectedTime(sender: UIButton) {
    // сл шаг
    self.step = 3
    
    switch sender.titleLabel?.text {
    case Buttons.short:
      self.time = 60
    case Buttons.average:
      self.time = 120
    case Buttons.long:
      self.time = 180
    case .none:
      print("none")
    case .some(_):
      print("some")
    }
    self.delegate?.updateTimerCount(count: self.time!)
//    switch sender.titleLabel?.text {
//      case Buttons.short:
//      self.delegate.updateT
//    }
    self.blockStart()
    // скрываем блок времени
    UIView.animate(withDuration: Constants.duration) {
      self.viewTime.alpha = 0
      self.viewTime.transform = CGAffineTransform(translationX: -100, y: 0)
      self.addSubview(self.viewStart)
    }
    UIView.animate(withDuration: Constants.duration,delay: Constants.delay) {
      self.viewStart.alpha = 1
      self.viewStart.transform = CGAffineTransform(scaleX: 1, y: 1)
      
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.duration) {
      print("delete view time")
      self.viewTime.removeFromSuperview()
    }

    
  }
  
  
  @objc func Start(sender: UIButton) {
    // скрываем блок времени
    UIView.animate(withDuration: Constants.duration) {
      self.viewStart.alpha = 0
      self.viewStart.transform = CGAffineTransform(translationX: -100, y: 0)
    }
    UIView.animate(withDuration: 2, delay: 2) {
      self.blurEffectViewLeft.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width/2, y: 0)
      self.blurEffectViewRight.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width/2, y: 0)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.viewStart.removeFromSuperview()
    }
    self.rootNumber(count: 3)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.rootNumber(count: 2)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
      self.rootNumber(count: 1)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
      self.delegate?.start()
      
    }
    
    

    // сл шаг
//    self.step = 3
    
  }
  
  //end
}

final private class RoundedCollisionImageView: UIImageView {
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    .ellipse
  }
}
