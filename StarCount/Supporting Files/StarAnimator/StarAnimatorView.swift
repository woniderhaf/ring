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

import UIKit

protocol StarAnimatorDelegate: class {
  func didStartRaining(count: Int)
}

final class StarAnimatorView: UIView {
  private enum Constants {
    static let animationDelay: TimeInterval = 0.1
    static let defaultAnimationDuration: TimeInterval = 0.5
    static let cleanupDelay: TimeInterval = 5
    static let starWidth: CGFloat = 16
    static let maxStarCount: Int = 10
  }

  weak var delegate: StarAnimatorDelegate?

  private var cleanupWorkItem: DispatchWorkItem?
  private lazy var animator: UIDynamicAnimator = {
    UIDynamicAnimator(referenceView: self)
  }()

  private lazy var collision: UICollisionBehavior = {
    let behavior = UICollisionBehavior(items: [])
    behavior.addBoundary(
      withIdentifier: "bottom" as NSCopying,
      from: CGPoint(x: 0, y: bounds.size.height),
      to: CGPoint(x: bounds.size.width, y: bounds.size.height)
    )
    behavior.addBoundary(
      withIdentifier: "right" as NSCopying,
      from: CGPoint(x: bounds.size.width, y: 0),
      to: CGPoint(x: bounds.size.width, y: bounds.size.height)
    )
    behavior.addBoundary(
      withIdentifier: "left" as NSCopying,
      from: CGPoint(x: 0, y: 0),
      to: CGPoint(x: 0, y: bounds.size.height)
    )
    animator.addBehavior(behavior)
    return behavior
  }()

  private lazy var gravity: UIGravityBehavior = {
    let behavior = UIGravityBehavior(items: [])
    behavior.magnitude = 0.4
    animator.addBehavior(behavior)
    return behavior
  }()

  private var rotationBehaviors: [UIDynamicItemBehavior] = []

  func rain(shouldClearCanvas: Bool) {
    if frame.size.width == 0 {
      return
    }

    if shouldClearCanvas {
      cleanup()
    }

    cleanupWorkItem?.cancel()
    cleanupWorkItem = DispatchWorkItem { [weak self] in
      self?.cleanup()
    }
    if let item = cleanupWorkItem {
      DispatchQueue.main.asyncAfter(deadline: .now() + Constants.cleanupDelay, execute: item)
    }

    let starsCount = Int.random(in: 1...Constants.maxStarCount)

    for i in 0..<starsCount {
      let star = RoundedCollisionImageView(
        frame: CGRect(
          x: CGFloat.random(in: 0 ..< frame.size.width - Constants.starWidth),
          y: -Constants.starWidth,
          width: Constants.starWidth,
          height: Constants.starWidth
        )
      )
      star.tintColor = .systemYellow
      star.alpha = 0

      star.image = UIImage(systemName: "star.fill")
      star.preferredSymbolConfiguration =
        .init(scale: [UIImage.SymbolScale.large, .medium, .small].randomElement() ?? .medium)
      star.sizeToFit()

      star.layer.shadowColor = UIColor.white.cgColor
      star.layer.shadowOpacity = 0.3
      star.layer.shadowOffset = .zero

      addSubview(star)

      gravity.addItem(star)
      collision.addItem(star)

      let dynamicBehavior = UIDynamicItemBehavior(items: [star])
      dynamicBehavior.elasticity = 0.4
      dynamicBehavior.addAngularVelocity(CGFloat.random(in: -10...10), for: star)
      rotationBehaviors.append(dynamicBehavior)

      animator.addBehavior(dynamicBehavior)

      UIView.animate(withDuration: Constants.defaultAnimationDuration, delay: Constants.animationDelay * Double(i)) {
        star.alpha = 1
      }
    }

    print("Dropped Stars: \(starsCount)")

    delegate?.didStartRaining(count: starsCount)
  }

  @objc private func cleanup() {
    subviews.forEach {
      $0.removeFromSuperview()
    }

    rotationBehaviors.forEach {
      animator.removeBehavior($0)
    }
    rotationBehaviors.removeAll()

    while !gravity.items.isEmpty {
      gravity.removeItem(gravity.items[0])
    }
    while !collision.items.isEmpty {
      collision.removeItem(collision.items[0])
    }
  }
}

final private class RoundedCollisionImageView: UIImageView {
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    .ellipse
  }
}
