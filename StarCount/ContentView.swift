
import SwiftUI
import Vision

struct ContentView: View {
  
  @StateObject private var gameLogicController = GameLogicController()
  
  @State  private  var overlayPoints: [ CGPoint ] = []
  
  @State  private  var PointsFace: [Path]?

  
  

  

  private func showCount(index: Int) -> some View {
    
    let text = Text("\(gameLogicController.successBadge)")
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
      
      // timer
      Label(gameLogicController.timeString,systemImage: "").font(.largeTitle).position(CGPoint(x: 100, y: 30))
      
      gameLogicController.isStart  ? showCount(index: gameLogicController.activeCircleIndex) : nil
      showFace()
      
      showEvadePoint(point: gameLogicController.evadePoints.first ?? CGPoint(x: 0, y: 0),index: 0)
      showEvadePoint(point: gameLogicController.evadePoints.count > 1 ? gameLogicController.evadePoints[1] : CGPoint(x: 0, y: 0),index: 1)
      showEvadePoint(point: gameLogicController.evadePoints.count > 2 ? gameLogicController.evadePoints[2] : CGPoint(x: 0, y: 0),index: 2)
      showEvadePoint(point: gameLogicController.evadePoints.count > 3 ? gameLogicController.evadePoints[3] : CGPoint(x: 0, y: 0),index: 3)
      
      StartAnimate(
        isStart: $gameLogicController.isStart,
        isRender: $gameLogicController.isRender,
        isAnimation: $gameLogicController.isAnimation,
        isFinish: $gameLogicController.isFinish,
        glasses: $gameLogicController.successBadge
      ) {count in
        gameLogicController.updateSpeed(speed: count)
      } numberOfStarsHandler: { number in
        
      } updateTimerCount: {count in
        gameLogicController.updateTimeCount(count: count)
      } setIsRender: {
        gameLogicController.setIsRender()
      } start: {
        gameLogicController.play()
      }
      
      ForEach(0 ..<  50) { i in
        
        gameLogicController.isStart && gameLogicController.activeCircleIndex == i && gameLogicController.countCircles > 0 ? RingAnimation(complection: gameLogicController.passCircle, arrayCircle: gameLogicController.viewsArray[i],activeIndex: gameLogicController.activeCircleIndex,index: i, speed: gameLogicController.speed) : nil
      }
      
      
    }
    .onAppear {
      gameLogicController.changeCountCircle(gameLogicController.viewsArray.count)
      gameLogicController.start()
      
      
    }
//    .overlay(
//      gameLogicController.isStart
//      ? RingAnimation(complection: gameLogicController.passCircle, arrayCircles: gameLogicController.viewsArray,activeIndex: gameLogicController.activeCircleIndex, speed: gameLogicController.speed)
//      : nil
//    )
    .edgesIgnoringSafeArea(.all)

    
   

  }
    
}

