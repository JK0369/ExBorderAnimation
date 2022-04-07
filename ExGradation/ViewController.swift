//
//  ViewController.swift
//  ExConicAnimation
//
//  Created by Jake.K on 2022/04/07.
//

import UIKit

class ViewController: UIViewController {
  private enum Color {
    static var gradientColors = [
      UIColor.systemBlue,
      UIColor.systemBlue.withAlphaComponent(0.7),
      UIColor.systemBlue.withAlphaComponent(0.4),
      UIColor.systemGreen.withAlphaComponent(0.3),
      UIColor.systemGreen.withAlphaComponent(0.7),
      UIColor.systemGreen.withAlphaComponent(0.3),
      UIColor.systemBlue.withAlphaComponent(0.4),
      UIColor.systemBlue.withAlphaComponent(0.7),
    ]
  }
  private enum Constants {
    static let gradientLocation = [Int](0..<Color.gradientColors.count)
      .map(Double.init)
      .map { $0 / Double(Color.gradientColors.count) }
      .map(NSNumber.init)
    static let cornerRadius = 30.0
    static let cornerWidth = 10.0
    static let viewSize = CGSize(width: 100, height: 350)
  }
  
  private lazy var sampleView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray
    view.layer.cornerRadius = Constants.cornerRadius
    view.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(view)
    return view
  }()
  private lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.text = "border 애니메이션 예제"
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    self.sampleView.addSubview(label)
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    NSLayoutConstraint.activate([
      self.infoLabel.centerYAnchor.constraint(equalTo: self.sampleView.centerYAnchor),
      self.infoLabel.centerXAnchor.constraint(equalTo: self.sampleView.centerXAnchor),
    ])
    NSLayoutConstraint.activate([
      self.sampleView.heightAnchor.constraint(equalToConstant: Constants.viewSize.width),
      self.sampleView.widthAnchor.constraint(equalToConstant: Constants.viewSize.height),
      self.sampleView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.sampleView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
    ])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.animateBorderGradation()
  }
  
  func animateBorderGradation() {
    // 1. 경계선에만 색상을 넣기 위해서 CAShapeLayer 인스턴스 생성
    let shape = CAShapeLayer()
    shape.path = UIBezierPath(
      roundedRect: self.sampleView.bounds,
      cornerRadius: self.sampleView.layer.cornerRadius
    ).cgPath
    shape.lineWidth = Constants.cornerWidth
    shape.cornerRadius = Constants.cornerRadius
    shape.strokeColor = UIColor.white.cgColor
    shape.fillColor = UIColor.clear.cgColor
    
    // 2. conic 그라데이션 효과를 주기 위해서 CAGradientLayer 인스턴스 생성 후 mask에 CAShapeLayer 대입
    let gradient = CAGradientLayer()
    gradient.frame = self.sampleView.bounds
    gradient.type = .conic
    gradient.colors = Color.gradientColors.map(\.cgColor) as [Any]
    gradient.locations = Constants.gradientLocation
    gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 1)
    gradient.mask = shape
    gradient.cornerRadius = Constants.cornerRadius
    self.sampleView.layer.addSublayer(gradient)
    
    // 3. 매 0.2초마다 마치 circular queue처럼 색상을 번갈아서 바뀌도록 구현
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
      gradient.removeAnimation(forKey: "myAnimation")
      let previous = Color.gradientColors.map(\.cgColor)
      let last = Color.gradientColors.removeLast()
      Color.gradientColors.insert(last, at: 0)
      let lastColors = Color.gradientColors.map(\.cgColor)
      
      let colorsAnimation = CABasicAnimation(keyPath: "colors")
      colorsAnimation.fromValue = previous
      colorsAnimation.toValue = lastColors
      colorsAnimation.repeatCount = 1
      colorsAnimation.duration = 0.2
      colorsAnimation.isRemovedOnCompletion = false
      colorsAnimation.fillMode = .both
      gradient.add(colorsAnimation, forKey: "myAnimation")
    }
  }
}
