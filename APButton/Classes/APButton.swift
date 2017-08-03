//
//  APButton.swift
//  APButton
//
//  Created by Anton Plebanovich on 19.04.16.
//  Copyright © 2016 Anton Plebanovich. All rights reserved.
//

import UIKit


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
            
            configureEnabledForDependentViews(isEnabled: isEnabled)
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            guard !activityIndicator.isAnimating && isHighlighted != oldValue else { return }
            
            let changes: () -> () = {
                if self.buttonType == .custom {
                    let newAlpha = self.isHighlighted ? g_ButtonHighlightAlphaCoef : 1
                    self.imageView?.alpha = newAlpha
                    self.titleLabel?.alpha = newAlpha
                }
                
                self.configureHighlightForDependentViews(isHighlighted: self.isHighlighted)
            }
            
            let highightDuration = isTouchInside ? 0.0 : 0.3
            let duration = isHighlighted ? highightDuration : 0.3
            let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveLinear]
            if UIView.areAnimationsEnabled {
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    changes()
                }, completion: nil)
            } else {
                changes()
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Private Properties
    //-----------------------------------------------------------------------------
    
    private var animatingViewsOriginalAlphas = [UIView: CGFloat]()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let overlayView = UIView()
    
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
        configureEnabledForDependentViews(isEnabled: isEnabled)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Configuration
    //-----------------------------------------------------------------------------
    
    private func configureDisabledColor() {
        dependentViews?
            .flatMap({ $0 as? UILabel })
            .filter({ $0.textColor == titleColor(for: .normal) })
            .forEach({
                guard let disabledTextColor = titleColor(for: .disabled) else { return }
                
                $0.ap_disabledTextColor = disabledTextColor
            })
    }
    
    private func configureHighlightForDependentViews(isHighlighted: Bool) {
        if overlayColor != nil {
            overlayView.alpha = isHighlighted ? 1 : 0
        } else {
            guard let dependentViews = dependentViews else { return }
            
            for view in dependentViews {
                if let button = view as? APButton {
                    button.setHighlight(isHighlighted, ignoreDependentViews: true)
                } else {
                    view.ap_highlighted = isHighlighted
                }
            }
        }
    }
    
    private func configureEnabledForDependentViews(isEnabled: Bool) {
        guard let dependentViews = dependentViews else { return }
        
        dependentViews.flatMap({ $0 as? UILabel }).forEach({ $0.ap_disabled = !isEnabled })
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
        
        if let dependentViews = dependentViews {
            animatingViewsOriginalAlphas = [:]
            for view in dependentViews {
                animatingViewsOriginalAlphas[view] = view.alpha
                view.alpha = 0
            }
        }
        
        let changes: () -> () = {
            self.titleLabel?.alpha = 0
            self.imageView?.alpha = 0
        }
        
        if self.buttonType == .system {
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
    
    private func setHighlight(_ highlight: Bool, ignoreDependentViews: Bool) {
        if !ignoreDependentViews {
            configureHighlightForDependentViews(isHighlighted: highlight)
        }
    }
}
