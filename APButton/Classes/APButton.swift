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
    // MARK: - Types
    //-----------------------------------------------------------------------------
    
    public typealias Action = (APButton) -> ()
    
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
    @IBInspectable public var rounded: Bool = false { didSet { setNeedsLayout() } }
    
    /// Progress bar color
    @IBInspectable public var progressColor: UIColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1) {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Public Properties
    //-----------------------------------------------------------------------------
    
    /// Indicates if button is animating
    public private(set) var isAnimating = false
    
    /// Button loading counter
    public private(set) var loadingCounter = 0
    
    /// Action that will be performed on button tap
    public var action: Action? {
        didSet {
            configureAction()
        }
    }
    
    /// Progress bar progress. From 0 to 1.
    public var progress: CGFloat = 0 {
        didSet {
            // Clamp progress
            if progress > 1 {
                progress = 1
            } else if progress < 0 {
                progress = 0
            }
            
            _g_performInMain {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - UIButton Properties
    //-----------------------------------------------------------------------------
    
    public override var isHidden: Bool {
        didSet {
            guard oldValue != isHidden else { return }
            
            configureIsHiddenForDependentViews()
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            
            configureEnabled()
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue else { return }
            
            let changes: (_ animated: Bool) -> () = { animated in
                self.configureTitleAndImageView()
                
                if self.overlayColor != nil {
                    self.overlayView.alpha = self.isHighlighted ? 1 : 0
                } else {
                    self.configureHighlight(animated: animated)
                }
            }
            
            if UIView.areAnimationsEnabled && !isAnimating {
                let highightDuration = isTouchInside ? 0.0 : 0.3
                let duration = isHighlighted ? highightDuration : 0.3
                
                if duration > 0 {
                    
                    // We need to commit all existing changes before animation or it might looks weird.
                    UIView.performWithoutAnimation {
                        layoutIfNeeded()
                    }
                    
                    let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveLinear]
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
    
    private(set) public lazy var activityIndicator: UIActivityIndicatorView = {
        let ai: UIActivityIndicatorView
        if #available(tvOS 13.0, iOS 13.0, *) {
            ai = UIActivityIndicatorView(style: .medium)
        } else {
#if os(tvOS)
            ai = UIActivityIndicatorView(style: .white)
#else
            ai = UIActivityIndicatorView(style: .gray)
#endif
        }
        
        ai.isHidden = true
        ai.hidesWhenStopped = true
        ai.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        
        return ai
    }()
    
    private lazy var overlayView: UIView = {
        let ov = UIView()
        ov.accessibilityIdentifier = "overlayView"
        ov.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ov.backgroundColor = overlayColor
        ov.alpha = 0
        ov.isUserInteractionEnabled = false
        
        return ov
    }()
    
    private var defaultBorderColor: CGColor?
    private var isMadeBorderDisabled = false
    
    private lazy var progressView: UIView = {
        let progressView = UIView()
        progressView.backgroundColor = progressColor
        progressView.isUserInteractionEnabled = false
        progressView.accessibilityIdentifier = "progressView"
        
        return progressView
    }()
    
    //-----------------------------------------------------------------------------
    // MARK: - Initialization and Setup
    //-----------------------------------------------------------------------------
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        setup()
    }
    
    convenience public init(action: @escaping Action) {
        self.init()
        
        self.action = action
        configureAction()
    }
    
    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        setupAction()
        setupViews()
        
        adjustsImageWhenHighlighted = false
        
        configureDisabledColor()
        configureEnabled()
        configureHighlight(animated: false)
        configureIsHiddenForDependentViews()
    }
    
    private func setupAction() {
        addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
    }
    
    private func setupViews() {
        insertSubview(progressView, at: 0)
        
        dependentViews?.forEach({ _dependentViews.add($0) })
        dependentViews = nil
        
        // Set `accessibilityIdentifier` from dependent views if needed
        if accessibilityIdentifier == nil && title(for: .normal)?.isEmpty != false {
            accessibilityIdentifier = _dependentViews
                .allObjects
                .compactMap { $0.accessibilityIdentifier }
                .first
            ?? _dependentViews
                .allObjects
                .compactMap { ($0 as? UILabel)?.text }
                .first
        }
        
        addSubview(overlayView)
        overlayView.frame = bounds
        
        addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Configuration
    //-----------------------------------------------------------------------------
    
    private func configureAction() {
        if action != nil {
            addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        }
    }
    
    private func configureTitleAndImageView() {
        if isAnimating {
            self.titleLabel?.alpha = 0
            self.imageView?.alpha = 0
        } else if isHighlighted {
            self.titleLabel?.alpha = g_ButtonHighlightAlphaCoef
            self.imageView?.alpha = g_ButtonHighlightAlphaCoef
        } else {
            self.titleLabel?.alpha = 1
            self.imageView?.alpha = 1
        }
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
            .compactMap({ $0 as? UILabel })
            .filter({ $0.textColor == titleColor(for: .normal) })
            .forEach({
                guard let disabledTextColor = titleColor(for: .disabled) else { return }
                
                $0.ap_disabledTextColor = disabledTextColor
            })
    }
    
    private func configureIsHiddenForDependentViews() {
        _dependentViews.allObjects.forEach({ $0.ap_isHidden = isHidden })
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
        _dependentViews.allObjects.compactMap({ $0 as? UILabel }).forEach({ $0.ap_disabled = !isEnabled })
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - UIView Methods
    //-----------------------------------------------------------------------------
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if rounded {
            layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2
        }
        
        configureTitleAndImageView()
        overlayView.layer.cornerRadius = layer.cornerRadius
        
        insertSubview(progressView, at: 0)
        progressView.isHidden = !isAnimating
        progressView.layer.cornerRadius = layer.cornerRadius
        let animated = progressView.frame != .zero
        let changes: () -> () = {
            self.progressView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width * self.progress, height: self.bounds.size.height)
        }
        if animated && isAnimating {
            UIView.animate(withDuration: 0.05, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear], animations: {
                changes()
            }, completion: nil)
        } else {
            changes()
        }
        
        // Overlay should be on top
        bringSubviewToFront(overlayView)
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - UIButton Methods
    //-----------------------------------------------------------------------------
    
    public override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        
        configureDisabledColor()
    }
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        // For some reason system button doesn't set text properly when overridden
        if buttonType == .system {
            titleLabel?.text = currentTitle
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Public Methods
    //-----------------------------------------------------------------------------
    
    /// Starts loading animation
    public func startAnimating() {
        _g_performInMain {
            guard !self.isAnimating else { return }
            
            self.isAnimating = true
            self.isHighlighted = false
            self.isUserInteractionEnabled = false
            
            self.animatingViewsOriginalAlphas = [:]
            self._dependentViews.allObjects.forEach({
                self.animatingViewsOriginalAlphas[$0] = $0.alpha
                $0.alpha = 0
            })
            
            let changes: () -> () = {
                self.configureTitleAndImageView()
            }
            
            self.titleLabel?.layer.removeAllAnimations()
            self.imageView?.layer.removeAllAnimations()
            if self.buttonType == .system {
                DispatchQueue.main.async { changes() }
            } else {
                changes()
            }
            
            self.activityIndicator.startAnimating()
        }
    }
    
    /// Stops loading animation
    public func stopAnimating() {
        _g_performInMain {
            guard self.isAnimating else { return }
            
            self.isAnimating = false
            
            for (view, alpha) in self.animatingViewsOriginalAlphas {
                view.alpha = alpha
            }
            self.animatingViewsOriginalAlphas = [:]
            
            let changes: () -> () = {
                self.configureTitleAndImageView()
            }
            
            self.titleLabel?.layer.removeAllAnimations()
            self.imageView?.layer.removeAllAnimations()
            if self.buttonType == .system {
                DispatchQueue.main.async { changes() }
            } else {
                changes()
            }
            
            self.activityIndicator.stopAnimating()
            self.isUserInteractionEnabled = true
            self.progress = 0
        }
    }
    
    /// Increases counter and starts animating
    public func increaseLoadingCounter() {
        _g_performInMain {
            self.loadingCounter += 1
            self.startAnimating()
        }
    }
    
    /// Decreases counter and stops animating if counter is zero.
    /// - parameter nullify: Should nullify counter and force stop loading animation?
    public func decreaseLoadingCounter(nullify: Bool = false) {
        _g_performInMain {
            if nullify {
                self.loadingCounter = 0
            } else {
                self.loadingCounter -= 1
            }
            
            if self.loadingCounter <= 0 {
                self.stopAnimating()
                self.loadingCounter = 0
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Actions
    //-----------------------------------------------------------------------------
    
    @IBAction private func onTap(_ sender: Any) {
        action?(self)
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
