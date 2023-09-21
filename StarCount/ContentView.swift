
import SwiftUI
import Vision

struct ContentView: View {
  
  @StateObject private var gameLogicController = GameLogicController()
  
  
  @State  private  var overlayPoints: [ CGPoint ] = []
  
  @State  private  var PointsFace: [Path]?
  @ViewBuilder
  
    
    private func successBadge(number: Int) -> some View {
      
      return Image(systemName: "\(number).circle.fill")
              .resizable()
              .imageScale(.large)
              .foregroundColor(.white)
              .frame(width: 200, height: 200)
              .shadow(radius: 5)
    }
  

  private func show(index: Int) -> some View {
   
    return
    gameLogicController.shouldEvaluateResult && !gameLogicController.isShape ?
    Image(systemName: "circle.fill")
      .resizable()
      .imageScale(.large)
      .foregroundColor(.red)
      .frame(width: 50, height: 50)
      .position(x: gameLogicController.viewsArray[index].frame.origin.x,y: gameLogicController.viewsArray[index].frame.origin.y)
    :
    Image(systemName: "circle.fill")
      .resizable()
      .imageScale(.large)
      .foregroundColor(.red)
      .frame(width: 0, height: 0)
      .position(x: 0,y: 0)
   
  }
  
  

  private func showCount(index: Int) -> some View {
    
    var text = Text("\(gameLogicController.successBadge)")
      .position(x: UIScreen.main.bounds.width/2,y: 30)
      .font(.system(size: 46,weight: .bold))

    return text
  }
  
  
  private func updatePointsFace(observedFaces: [Path]) {
    PointsFace = observedFaces
  }
  
  private func showFace() -> some View {
    if gameLogicController.startEvade {
      gameLogicController.changePositionFace(path: PointsFace?.first ?? Path())
    }
    if !gameLogicController.isShape {
    } else if gameLogicController.evadePoints.count > 0 && PointsFace?.first?.currentPoint?.x ?? 0 > 0 {
      let currentPoint:CGPoint = PointsFace?.first?.currentPoint ?? CGPoint(x: 0, y: 0)
      if gameLogicController.side {
        
        if gameLogicController.evadePoints[0].x - currentPoint.x  < 100 && currentPoint.y < gameLogicController.evadePoints[0].y && gameLogicController.evadePoints[0].y < currentPoint.y + 80   {
          gameLogicController.successEvadePoint(point: 0)
        }
        if gameLogicController.evadePoints[1].x - currentPoint.x < 100 && currentPoint.y < gameLogicController.evadePoints[1].y && gameLogicController.evadePoints[1].y < currentPoint.y + 80  {
          
          gameLogicController.successEvadePoint(point: 1)
        }
        if gameLogicController.evadePoints[2].x - currentPoint.x < 100 && currentPoint.y < gameLogicController.evadePoints[2].y && gameLogicController.evadePoints[2].y < currentPoint.y + 80  {
          
          gameLogicController.successEvadePoint(point: 2)
          
    
        }
        if gameLogicController.evadePoints[3].x - currentPoint.x < 100 && currentPoint.y < gameLogicController.evadePoints[3].y && gameLogicController.evadePoints[3].y < currentPoint.y + 80  {
          
          gameLogicController.successEvadePoint(point: 3)
          
          if gameLogicController.shouldEvaluateResult {
            gameLogicController.changeSide()
          }
        }
        
      } else {
        
        if gameLogicController.evadePoints[0].x - currentPoint.x  > 15 && currentPoint.y < gameLogicController.evadePoints[0].y && gameLogicController.evadePoints[0].y < currentPoint.y + 100   {
          gameLogicController.successEvadePoint(point: 0)
        }
        if gameLogicController.evadePoints[1].x - currentPoint.x > 15 && currentPoint.y < gameLogicController.evadePoints[1].y && gameLogicController.evadePoints[1].y < currentPoint.y + 100  {
          
          gameLogicController.successEvadePoint(point: 1)
        }
        if gameLogicController.evadePoints[2].x - currentPoint.x > 15 && currentPoint.y < gameLogicController.evadePoints[2].y && gameLogicController.evadePoints[2].y < currentPoint.y + 100  {
          
          gameLogicController.successEvadePoint(point: 2)
          
        }
        
        if gameLogicController.evadePoints[3].x - currentPoint.x > 15 && currentPoint.y < gameLogicController.evadePoints[3].y && gameLogicController.evadePoints[3].y < currentPoint.y + 100  {
          
          gameLogicController.successEvadePoint(point: 3)
          

          if gameLogicController.shouldEvaluateResult {
            gameLogicController.changeSide()
          }
          
        }
        
      }
      
    }
   
    return PointsFace?.first?.stroke(Color.red, lineWidth: gameLogicController.isShape ? 2 : 0)

  }
  
  
  
  private func showEvadePoint(point:CGPoint, index: Int) -> some View {
    
    return Image(systemName: "circle.fill")
      .resizable()
      .imageScale(.large)
      .foregroundColor(gameLogicController.successPoints.contains(index) ? .green : gameLogicController.failePoints.contains(index) ? .red : .white)
      .frame(width: point.x > 0 ? 20 : 0, height: 20)
      .position(
        x: point.x,
        y: point.y)
  }
  
  
  let viewHeight = UIScreen.main.bounds.size.height
  let viewWidth = UIScreen.main.bounds.size.width
  


  var body: some View {
    
    ZStack {
      CameraView(
        pointsProcessorHandler: { points in
          
          if(gameLogicController.isStart) {
            gameLogicController.checkStarsCount(points)
          }
          
      },
        pointsProcessorFace:  {data in
        
        updatePointsFace(observedFaces: data)
        
        }
      )
      gameLogicController.isStart  ? showCount(index: gameLogicController.activeCircleIndex) : nil
      showFace()
      showEvadePoint(point: gameLogicController.evadePoints.first ?? CGPoint(x: 0, y: 0),index: 0)
      showEvadePoint(point: gameLogicController.evadePoints.count > 1 ? gameLogicController.evadePoints[1] : CGPoint(x: 0, y: 0),index: 1)
      showEvadePoint(point: gameLogicController.evadePoints.count > 2 ? gameLogicController.evadePoints[2] : CGPoint(x: 0, y: 0),index: 2)
      showEvadePoint(point: gameLogicController.evadePoints.count > 3 ? gameLogicController.evadePoints[3] : CGPoint(x: 0, y: 0),index: 3)
      
      StartAnimate(isStart: $gameLogicController.isStart,isRender: $gameLogicController.isRender, isAnimation: $gameLogicController.isAnimation) {count in
        
      } setIsRender: {
        gameLogicController.setIsRender()
      } start: {
        gameLogicController.play()
      }
      
    }
    .onAppear {
      gameLogicController.changeCountCircle(gameLogicController.viewsArray.count)
      gameLogicController.start()
    }
    .overlay(
      gameLogicController.isStart ? show(index: gameLogicController.activeCircleIndex): nil
    )
    .edgesIgnoringSafeArea(.all)

    
   

  }
    
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
