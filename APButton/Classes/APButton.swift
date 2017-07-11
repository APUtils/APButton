//
//  APButton.swift
//  APButton
//
//  Created by Anton Plebanovich on 19.04.16.
//  Copyright © 2016 Anton Plebanovich. All rights reserved.
//

import UIKit


private let highlightedAlpha: CGFloat = 0.499
private let disabledAlpha: CGFloat = 0.499
private let overlayAlpha: CGFloat = 0.5

//-----------------------------------------------------------------------------
// MARK: - Helper Functions
//-----------------------------------------------------------------------------

private func isCGFloatsEqual(first: CGFloat, second: CGFloat) -> Bool {
    if abs(first - second) < 0.0001 {
        return true
    } else {
        return false
    }
}

//-----------------------------------------------------------------------------
// MARK: - Class Implementation
//-----------------------------------------------------------------------------

public class APButton: UIButton {
    
    //-----------------------------------------------------------------------------
    // MARK: - @IBOutlet
    //-----------------------------------------------------------------------------
    
    /// Dependet views to animate according to button state change
    @IBOutlet public var dependentViews: [UIView]?
    
    //-----------------------------------------------------------------------------
    // MARK: - @IBInspectable
    //-----------------------------------------------------------------------------
    
    /// Instead of dim all views put 0.5 white overlay above button
    @IBInspectable public var isUseHighlightedOverlay: Bool = false
    
    /// Make button round
    @IBInspectable public var rounded: Bool = false
    
    //-----------------------------------------------------------------------------
    // MARK: - UIButton Properties
    //-----------------------------------------------------------------------------
    
    override public var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            
            if isEnabled {
                setTitleColor(enabledTitleColor, for: .normal)
                layer.borderColor = enabledBorderColor
            } else {
                enabledTitleColor = titleColor(for: .normal)
                enabledBorderColor = layer.borderColor
                
                setTitleColor(.lightGray, for: .normal)
                layer.borderColor = UIColor.lightGray.cgColor
            }
            
            configureEnabledForDependentViews(isEnabled: isEnabled)
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            let duration = isHighlighted ? 0.01 : 0.2
            let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.configureHighlight(isHighlighted: self.isHighlighted)
                self.configureHighlightForDependentViews(isHighlighted: self.isHighlighted)
            }, completion: nil)
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Private Properties
    //-----------------------------------------------------------------------------
    
    private var animatingViewsOriginalAlphas = [UIView: CGFloat]()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var buttonImage: UIImage?
    private let overlayView = UIView()
    private var enabledTitleColor: UIColor?
    private var enabledBorderColor: CGColor?
    
    //-----------------------------------------------------------------------------
    // MARK: - Initialization, Setup and Configuration
    //-----------------------------------------------------------------------------
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        adjustsImageWhenHighlighted = false
        
        addSubview(overlayView)
        overlayView.frame = bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.backgroundColor = UIColor.white
        overlayView.alpha = 0
        
        addSubview(activityIndicator)
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        let msk: UIViewAutoresizing = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        activityIndicator.autoresizingMask = msk
        
        enabledTitleColor = titleLabel?.textColor
        enabledBorderColor = layer.borderColor
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - UIView Methods
    //-----------------------------------------------------------------------------
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if rounded {
            layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2
        }
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
        
        buttonImage = imageView?.image
        setImage(nil, for: UIControlState())
        titleLabel?.alpha = 0
        activityIndicator.startAnimating()
    }
    
    public func stopAnimating() {
        for (view, alpha) in animatingViewsOriginalAlphas {
            view.alpha = alpha
        }
        animatingViewsOriginalAlphas = [:]
        
        if let buttonImage = buttonImage {
            setImage(buttonImage, for: UIControlState())
            self.buttonImage = nil
        }
        titleLabel?.alpha = 1
        
        activityIndicator.stopAnimating()
        isUserInteractionEnabled = true
    }
    
    public func setHighlight(_ highlight: Bool, ignoreDependentViews: Bool) {
        configureHighlight(isHighlighted: highlight)
        
        if !ignoreDependentViews {
            configureHighlightForDependentViews(isHighlighted: highlight)
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Private Methods
    //-----------------------------------------------------------------------------
    
    private func configureHighlight(isHighlighted: Bool) {
        if isUseHighlightedOverlay {
            let newAlpha = isHighlighted ? overlayAlpha : 0
            
            overlayView.alpha = newAlpha
        } else {
            let newAlpha = isHighlighted ? highlightedAlpha : 1
            let oldAlpha = isHighlighted ? 1 : highlightedAlpha
            
            if isCGFloatsEqual(first: alpha, second: oldAlpha) {
                alpha = newAlpha
            }
        }
    }
    
    private func configureHighlightForDependentViews(isHighlighted: Bool) {
        guard let dependentViews = dependentViews else { return }
        
        let newAlpha = isHighlighted ? highlightedAlpha : 1
        let oldAlpha = isHighlighted ? 1 : highlightedAlpha
        
        for view in dependentViews {
            if let button = view as? APButton {
                button.setHighlight(isHighlighted, ignoreDependentViews: true)
            } else {
                if isCGFloatsEqual(first: view.alpha, second: oldAlpha) {
                    view.alpha = newAlpha
                }
            }
        }
    }
    
    private func configureEnabledForDependentViews(isEnabled: Bool) {
        guard let dependentViews = dependentViews else { return }
        
        let newAlpha = isEnabled ? 1 : disabledAlpha
        let oldAlpha = isEnabled ? disabledAlpha : 1
        
        for view in dependentViews {
            if isCGFloatsEqual(first: view.alpha, second: oldAlpha) {
                view.alpha = newAlpha
            }
        }
    }
}
