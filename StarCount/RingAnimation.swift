import SwiftUI
 
struct RingAnimation:View {
  
  @State private var drawingStroke = true
//    didSet {
//      print("Change: \(drawingStroke)")
//      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//        drawingStroke = true
//        drawingStroke = false
//            }
//    }
  
  @State var workItem: DispatchWorkItem?
  
    init(drawingStroke: Bool = true, complection: @escaping () -> Void, arrayCircle: UIView, activeIndex: Int, index: Int, speed: Double) {
      self.drawingStroke = drawingStroke
      self.complection = complection
      self.arrayCircle = arrayCircle
      
      self.activeIndex = activeIndex
      self.index = index
      self.speed = speed
      
      

    }
    

    var complection: () -> Void
    var arrayCircle: UIView
  
    var activeIndex:Int
    @State var index = 0
    @State var speed:Double
  
  
  func an(spped:Double) -> Animation {
       
    return Animation.linear(duration: drawingStroke ? 0 : speed)
  }
  
  



  
  var body: some View {
    if #available(iOS 16.0, *) {
      
     return Circle()
        .frame(width:50)
        .foregroundStyle(.green)
        .position(CGPoint(x: arrayCircle.frame.origin.x, y: arrayCircle.frame.origin.y))
        .overlay {
//          drawingStroke.toggle()
          Circle()
            .trim(from: drawingStroke ? 0 : 1 ,to: 1)
            .stroke(drawingStroke ? Color.white.gradient : Color.red.gradient,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .frame(width: 60)
            .position(CGPoint(x: arrayCircle.frame.origin.x, y: arrayCircle.frame.origin.y))
        }
        .onAppear {
          drawingStroke.toggle()
          print("index: \(index)")
          workItem = DispatchWorkItem {
            complection()
          }
          
          DispatchQueue.main.asyncAfter(deadline: .now() + speed, execute: workItem!)
        }
        .onDisappear {
          print("onDisappear")
          workItem?.cancel()
        }
        .animation(an(spped: speed),value: drawingStroke)
    } else {
      return Circle()
        .foregroundColor(.black)
        .position(arrayCircle.frame.origin)
    }
  }
  
  
}


