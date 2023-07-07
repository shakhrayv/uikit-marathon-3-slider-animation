//
//  ViewController.swift
//  uikit-marathon-3-slider-animation
//
//  Created by Vladislav Shakhray on 07/07/2023.
//

import UIKit

class ViewController: UIViewController {

    let initialViewSize: CGFloat = 80
    let scalingFactor: CGFloat = 1.5
    
    var timer: Timer?

    private var safeAreaInsets: UIEdgeInsets!

    private lazy var square = {
        let view = UIView(
            frame: .init(x: safeAreaInsets.left, y: 100, width: initialViewSize, height: initialViewSize)
        )
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12.0
        return view
    }()
    
    var containerView = UIView()
    
    private lazy var slider = {
        let slider = UISlider(
            frame: .init(x: safeAreaInsets.left, y: 200, width: view.frame.width - safeAreaInsets.left - safeAreaInsets.right, height: 100.0)
        )
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        
        slider.setValue(0.0, animated: false)
        
        slider.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderReleased), for: .touchUpInside)
        
        return slider
    }()

    private func computeTransforms(_ value: Float) -> (CGAffineTransform, CGAffineTransform, CGAffineTransform) {
        let progress = CGFloat(value)

        let maxTranslationX = view.frame.width - safeAreaInsets.left - safeAreaInsets.right - initialViewSize * (1 + scalingFactor) / 2.0
        let translation = CGAffineTransform(translationX: maxTranslationX * progress, y: 0)
        
        let rotation = CGAffineTransform(rotationAngle: 90 / 180.0 * CGFloat.pi * progress)
        
        let currentScale = scalingFactor * progress + 1 * (1 - progress)
        let scale = CGAffineTransform(scaleX: currentScale, y: currentScale)

        return (translation, rotation, scale)
    }

    @objc func sliderValueDidChange(_ sender: UISlider? = nil) {
        let (translation, rotation, scale) = computeTransforms(slider.value)
        containerView.transform = translation
        square.transform = rotation.concatenating(scale)
    }
    
    @objc func sliderReleased(_ sender: UISlider? = nil) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] _ in
            self?.slider.value += 0.005
            if self?.slider.value ?? 2.0 >= 1.0 {
                self?.timer?.invalidate()
                self?.timer = nil
            }

        }
        
        let (translation, rotation, scale) = computeTransforms(1.0)
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }
            self.containerView.transform = translation
            self.square.transform = rotation.concatenating(scale)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard safeAreaInsets == nil else { return }
        
        safeAreaInsets = view.layoutMargins
        view.addSubview(containerView)
        containerView.addSubview(square)
        view.addSubview(slider)
        containerView.frame = square.frame
        square.frame = containerView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

