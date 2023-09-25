
import UIKit
import SwiftUI

protocol StartAnimateDelegate: AnyObject {
  func didStartRaining(count: Int)
  func start()
  func updateTimerCount(count:Int)
  func updateSpeed(speed:Double)
  var isFinish:Bool { get }
}


final class StarAnimatorView: UIView {
  
  
  var speed:Double?
  var speedString:String?
  var time: Int?
  var timeString: String = ""
  
  var isFinish = false
  
  var step: Int = 1 // 1 - speed / 2 - time / 3 - start
  
  // выбранные настройки
  var activeSpeed: String?
  var activeTime: String?
    
  private enum Constants {
    static let duration: TimeInterval = 0.5
    static let delay: TimeInterval = 0.1
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
  let viewFinish = UIView()
  
  @objc func animationButtonDown(sender: UIButton) {
    sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
  }
 
  @objc func animationButtonUp(sender: UIButton) {
    
    sender.transform = CGAffineTransform(scaleX: 1, y: 1)
    switch sender.titleLabel?.text {
    case Buttons.fast:
      self.speed = 1
      self.delegate?.updateSpeed(speed: 1)
    case Buttons.slow:
      self.speed = 1.5
      self.delegate?.updateSpeed(speed: 1.5)
    case Buttons.dinamic:
      self.speed = 0.8
      self.delegate?.updateSpeed(speed: 0.8)
    case .none:
      self.speed = 1
      self.delegate?.updateSpeed(speed: 1)
    case .some(_):
      self.speed = 1
      self.delegate?.updateSpeed(speed: 1)
    }
  
    
    self.speedString = sender.titleLabel?.text
   
    
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
  
  
  func finish(glasses:Int) {

    
    if (!isFinish) {
      
      self.viewFinish.layer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 200, y: UIScreen.main.bounds.height/2 - 150, width: 400, height: 300)
      self.viewFinish.layer.cornerRadius = 50
      self.viewFinish.backgroundColor = .white.withAlphaComponent(Constants.backgroundAlpha)
      self.viewFinish.addSubview(Title(text: "Результат",parent: viewSpeed))
      self.viewFinish.alpha = 0
      self.viewFinish.addSubview(Text(text: "Набрано очков: \(glasses)", frame: CGRect(x: 30, y: 50, width: self.viewFinish.bounds.width, height: 40), font: .systemFont(ofSize: 22,weight: .bold), color: .black, textAlignment: .left))
      self.viewFinish.addSubview(Button(title: "Начать заново", key: 2, parent: self.viewFinish, action: #selector(repeatPlay) ))
      self.viewFinish.addSubview(Button(title: "Закрыть", key: 3, parent: self.viewFinish, action: #selector(closePlay) ))
      self.viewFinish.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      print("add subview")
      addSubview(viewFinish)
      UIView.animate(withDuration: Constants.duration, delay: Constants.delay) {
        self.viewFinish.alpha = 1
        self.viewFinish.transform = CGAffineTransform(scaleX: 1, y: 1)
      }
      isFinish = true
    }
    
  }
  
  @objc func repeatPlay() {
    
    self.delegate?.updateTimerCount(count: self.time!)
    self.delegate?.updateSpeed(speed: self.speed!)
    UIView.animate(withDuration: Constants.duration) {
      self.viewFinish.alpha = 0
      self.viewFinish.transform = CGAffineTransform(translationX: -100, y: 0)
    }
    
    self.rootNumber(count: 3)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.rootNumber(count: 2)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.rootNumber(count: 1)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.viewFinish.transform = CGAffineTransform(translationX: 0, y: 0)
      print("remove viewFinish")
      self.viewFinish.subviews.map {
        $0.removeFromSuperview()
      }
      self.viewFinish.removeFromSuperview()
     
      self.delegate?.start()
      self.isFinish = false
      
    }
   

  }
  
  @objc func closePlay() {
    print("close play")
//    self.viewStart.removeFromSuperview()
//    self.viewStart.subviews.forEach{$0.removeFromSuperview()}
//    self.viewSpeed.removeFromSuperview()
//    self.viewSpeed.subviews.forEach{$0.removeFromSuperview()}
//    self.viewTime.removeFromSuperview()
//    self.viewTime.subviews.forEach{$0.removeFromSuperview()}
//    blockTime()
//    blockSpeed()
//    blockStart()
    self.viewFinish.removeFromSuperview()
    UIView.animate(withDuration: Constants.duration) {
      self.viewFinish.alpha = 0
      self.viewFinish.transform = CGAffineTransform(translationX: -100, y: 0)
    }
    self.viewSpeed.transform = CGAffineTransform(translationX: 0, y: 0)
    self.viewSpeed.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    self.viewSpeed.alpha = 0
    addSubview(self.viewSpeed)
    UIView.animate(withDuration: Constants.duration,delay: Constants.delay) {
      self.viewSpeed.alpha = 1
      self.viewSpeed.transform = CGAffineTransform(scaleX: 1, y: 1)
      
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
    
    UIView.animate(withDuration: 2) {
      let scale = 4.0
      label.alpha = 1
      label.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    UIView.animate(withDuration: 1,delay: 1) {
      label.alpha = 0
    }
  }
  



  func rain(complection: () -> Void) {
    

    if frame.size.width == 0 {
      return
    }
    
    
    let speed = blockSpeed()
    blockTime()
    
    
    
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
    
    viewStart.addSubview(Text(text: "Скорость: \(self.speedString!)",
                              frame: CGRect(x: 20, y: 80, width: 300, height: 30),
                              font: .systemFont(ofSize: 20),
                              color: .black,
                              textAlignment: .left
                             ))

    viewStart.addSubview(Text(text: "Время: \(self.timeString)",
                              frame: CGRect(x: 20, y: 120, width: 300, height: 30),
                              font: .systemFont(ofSize: 20),
                              color: .black,
                              textAlignment: .left
                             ))
    
    viewStart.addSubview(Button(title: "Старт",key: 3,parent: viewStart,action: #selector(Start)))
    viewStart.addSubview(BackButton(parent: viewStart))
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
    
    let button = UIButton()
    let configuration = UIImage.SymbolConfiguration(pointSize: 50)
    let image = UIImage(systemName: "arrowshape.backward.circle",withConfiguration: configuration)
    
    button.tintColor = .gray
    button.setImage(image, for: .normal)
    button.backgroundColor = .clear
    button.layer.frame = CGRect(x: 30, y: 10, width: 50, height: 50)
    button.addTarget(self, action: #selector(BackAction), for: .touchDown)
    return button
  }
  
  @objc func BackAction(sender:UIButton) {
    
    if step == 2 {
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
        
        self.viewTime.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.viewTime.removeFromSuperview()
        self.step = 1
      }
    } else if step == 3 {
      // возвращаем блок времени
      self.viewTime.alpha = 0
      self.viewTime.transform = CGAffineTransform(translationX: -100, y: 0)
      addSubview(self.viewTime)
      // анимация ичезновения блока старта
      UIView.animate(withDuration: Constants.duration) {
        
        self.viewStart.alpha = 0
        self.viewStart.transform = CGAffineTransform(scaleX: 0.8,y: 0.8)
        
      }
      // анимация появления блока времени
      UIView.animate(withDuration: Constants.duration, delay:Constants.delay) {
        self.viewTime.alpha = 1
        self.viewTime.transform = CGAffineTransform(translationX: 0,y: 0)
        
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + Constants.duration) {
        print("delete view start ")
        self.viewStart.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.viewStart.subviews.forEach {$0.removeFromSuperview()}
        self.viewStart.removeFromSuperview()
        self.step = 2
      }
    }
    
   
  }
  
  @objc func SelectedTime(sender: UIButton) {
    // сл шаг
    self.step = 3
    
    switch sender.titleLabel?.text {
    case Buttons.short:
      self.time = 60
      self.timeString = Buttons.short
    case Buttons.average:
      self.time = 120
      self.timeString = Buttons.average
    case Buttons.long:
      self.time = 180
      self.timeString = Buttons.long
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
//    UIView.animate(withDuration: 2, delay: 2) {
//      self.blurEffectViewLeft.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width/2, y: 0)
//      self.blurEffectViewRight.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width/2, y: 0)
//    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.viewStart.subviews.forEach { $0.removeFromSuperview()}
      self.viewFinish.subviews.forEach { $0.removeFromSuperview()}
      self.viewStart.removeFromSuperview()
      self.viewFinish.removeFromSuperview()
    }
    self.rootNumber(count: 3)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.rootNumber(count: 2)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.rootNumber(count: 1)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.delegate?.start()
      self.isFinish = false
    }
    
  }
  
  
  
  //end
}

final private class RoundedCollisionImageView: UIImageView {
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    .ellipse
  }
}
