//
//  APButton.swift
//  APButton
//
//  Created by Anton Plebanovich on 19.04.16.
//  Copyright © 2016 Anton Plebanovich. All rights reserved.
//

import UIKit
import QuartzCore


let g_ButtonHighlightAlphaCoef: CGFloat = 0.2


public class APButton: UIButton {
    
    //-----------------------------------------------------------------------------
    // MARK: - @IBOutlet UIButton
    //-----------------------------------------------------------------------------
    
    /// Dependet views to animate according to button state change
    @IBOutlet public var dependentViews: [UIView]?
    
    //-----------------------------------------------------------------------------
    // MARK: - @IBInspectable
    //-----------------------------------------------------------------------------
    
    /// If overlay color isn't nil button won't dim depending views but instead show overlay.
    @IBInspectable public var overlayColor: UIColor?
    
    /// Make button round
    @IBInspectable public var rounded: Bool = false
    
    //-----------------------------------------------------------------------------
    // MARK: - UIButton Properties
    //-----------------------------------------------------------------------------
    
    override public var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            
            configureEnabled()
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            guard !activityIndicator.isAnimating && isHighlighted != oldValue else { return }
            
            let changes: (_ animated: Bool) -> () = { animated in
                if self.buttonType == .custom {
                    let newAlpha = self.isHighlighted ? g_ButtonHighlightAlphaCoef : 1
                    self.imageView?.alpha = newAlpha
                    self.titleLabel?.alpha = newAlpha
                }
                
                if self.overlayColor != nil {
                    self.overlayView.alpha = self.isHighlighted ? 1 : 0
                } else {
                    self.configureHighlight(animated: animated)
                }
            }
            
            if UIView.areAnimationsEnabled {
                let highightDuration = isTouchInside ? 0.0 : 0.3
                let duration = isHighlighted ? highightDuration : 0.3
                
                if duration > 0 {
                    let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveLinear]
                    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                        changes(true)
                    }, completion: nil)
                } else {
                    changes(false)
                }
            } else {
                changes(false)
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Private Properties
    //-----------------------------------------------------------------------------
    
    private var _dependentViews = NSHashTable<UIView>(options: [.weakMemory])
    private var animatingViewsOriginalAlphas = [UIView: CGFloat]()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let overlayView = UIView()
    private var defaultBorderColor: CGColor?
    private var isMadeBorderDisabled = false
    
    //-----------------------------------------------------------------------------
    // MARK: - Initialization and Setup
    //-----------------------------------------------------------------------------
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        dependentViews?.forEach({ _dependentViews.add($0) })
        dependentViews = nil
        
        adjustsImageWhenHighlighted = false
        
        addSubview(overlayView)
        overlayView.frame = bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.backgroundColor = overlayColor
        overlayView.alpha = 0
        overlayView.isUserInteractionEnabled = false
        
        addSubview(activityIndicator)
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        let msk: UIViewAutoresizing = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        activityIndicator.autoresizingMask = msk
        
        configureDisabledColor()
        configureEnabled()
        configureHighlight(animated: false)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Configuration - Highlight
    //-----------------------------------------------------------------------------
    
    private func configureHighlight(animated: Bool) {
        configureHighlightForBorder(animated: animated)
        configureHighlightForDependentViews()
    }
    
    private func configureHighlightForBorder(animated: Bool) {
        if isHighlighted {
            // Change border color animated
            let oldColor = layer.borderColor
            defaultBorderColor = oldColor
            let newAlpha = (oldColor?.alpha ?? 1) * g_ButtonHighlightAlphaCoef
            let newColor = oldColor?.copy(alpha: newAlpha)
            setBorderColor(newColor, animated: animated)
        } else {
            if let defaultBorderColor = defaultBorderColor {
                setBorderColor(defaultBorderColor, animated: UIView.areAnimationsEnabled)
                self.defaultBorderColor = nil
            }
        }
    }
    
    private func configureHighlightForDependentViews() {
        _dependentViews.allObjects.forEach({ $0.ap_highlighted = isHighlighted })
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Configuration - Enabled/Disabled
    //-----------------------------------------------------------------------------
    
    private func configureDisabledColor() {
        _dependentViews.allObjects
            .flatMap({ $0 as? UILabel })
            .filter({ $0.textColor == titleColor(for: .normal) })
            .forEach({
                guard let disabledTextColor = titleColor(for: .disabled) else { return }
                
                $0.ap_disabledTextColor = disabledTextColor
            })
    }
    
    private func configureEnabled() {
        configureEnabledForBorder()
        configureEnabledForDependentViews()
    }
    
    private func configureEnabledForBorder() {
        if isEnabled {
            if isMadeBorderDisabled {
                layer.borderColor = titleColor(for: .normal)?.cgColor
                isMadeBorderDisabled = false
            }
        } else {
            let titleNormalColor = titleColor(for: .normal)?.cgColor
            if layer.borderColor == titleNormalColor {
                layer.borderColor = titleColor(for: .disabled)?.cgColor
                isMadeBorderDisabled = true
            }
        }
    }
    
    private func configureEnabledForDependentViews() {
        _dependentViews.allObjects.flatMap({ $0 as? UILabel }).forEach({ $0.ap_disabled = !isEnabled })
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - UIView Methods
    //-----------------------------------------------------------------------------
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if rounded {
            layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2
        }
        
        overlayView.layer.cornerRadius = layer.cornerRadius
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - UIButton Methods
    //-----------------------------------------------------------------------------
    
    public override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitleColor(color, for: state)
        
        configureDisabledColor()
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Public Methods
    //-----------------------------------------------------------------------------
    
    public func startAnimating() {
        isUserInteractionEnabled = false
        isHighlighted = false
        
        animatingViewsOriginalAlphas = [:]
        _dependentViews.allObjects.forEach({
            animatingViewsOriginalAlphas[$0] = $0.alpha
            $0.alpha = 0
        })
        
        let changes: () -> () = {
            self.titleLabel?.alpha = 0
            self.imageView?.alpha = 0
        }
        
        titleLabel?.layer.removeAllAnimations()
        imageView?.layer.removeAllAnimations()
        if buttonType == .system {
            DispatchQueue.main.async { changes() }
        } else {
            changes()
        }
        
        activityIndicator.startAnimating()
    }
    
    public func stopAnimating() {
        for (view, alpha) in animatingViewsOriginalAlphas {
            view.alpha = alpha
        }
        animatingViewsOriginalAlphas = [:]
        
        titleLabel?.alpha = 1
        imageView?.alpha = 1
        activityIndicator.stopAnimating()
        isUserInteractionEnabled = true
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Private Methods
    //-----------------------------------------------------------------------------
    
    private func setBorderColor(_ color: CGColor?, animated: Bool) {
        layer.removeAnimation(forKey: "borderColorAnimation")
        
        if animated {
            let animation = CABasicAnimation(keyPath: "borderColor")
            animation.fromValue = layer.borderColor
            animation.toValue = color
            animation.duration = 0 // Inherit main animation duration
            animation.timingFunction = CATransaction.animationTimingFunction()
            
            layer.add(animation, forKey: "borderColorAnimation")
        }
        
        layer.borderColor = color
    }
}
