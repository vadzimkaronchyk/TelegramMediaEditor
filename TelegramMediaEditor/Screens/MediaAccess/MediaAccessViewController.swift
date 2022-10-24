//
//  MediaAccessViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/9/22.
//

import Lottie
import UIKit
import Photos

final class MediaAccessViewController: UIViewController {
    
    private let containerView = UIView()
    private let animationView = AnimationView(name: "duck")
    private let titleLabel = UILabel()
    private let accessButton = ShimmerButton(type: .system)
    
    var onAccessGranted: VoidClosure?
    
    private var didBecomeActiveNotificationObserver: NSObjectProtocol?
    
    override func loadView() {
        super.loadView()
        
        setupLayout()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animationView.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        accessButton.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        animationView.stop()
        accessButton.stopAnimation()
    }
}

private extension MediaAccessViewController {
    
    func setupLayout() {
        view.addSubview(containerView)
        view.addSubview(animationView)
        view.addSubview(titleLabel)
        view.addSubview(accessButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        accessButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 144/390),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor),
            animationView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: accessButton.topAnchor, constant: -28),
            accessButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            accessButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            accessButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            accessButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupViews() {
        setupView()
        setupAnimationView()
        setupTitleLabel()
        setupAccessButton()
    }
    
    func setupView() {
        view.backgroundColor = .black
    }
    
    func setupAnimationView() {
        animationView.loopMode = .loop
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Access Your Photos and Videos"
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    func setupAccessButton() {
        accessButton.backgroundColor = .systemBlue
        accessButton.layer.cornerRadius = 10
        accessButton.layer.cornerCurve = .continuous
        accessButton.setTitle("Allow Access", for: .normal)
        accessButton.setTitleColor(.white, for: .normal)
        accessButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        accessButton.addTarget(self, action: #selector(accessButtonTapped), for: .touchUpInside)
    }
    
    @objc func accessButtonTapped(_ button: UIButton) {
        let status = PHPhotoLibrary.authorizationStatus()
        handlePhotoLibraryAuthorizationStatus(status)
    }
    
    func handlePhotoLibraryAuthorizationStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestPhotoLibraryAuthorization()
        case .restricted, .denied:
            presentRestrictedAccessWarningAlert()
        case .authorized, .limited:
            onAccessGranted?()
        default:
            break
        }
    }
    
    func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.handlePhotoLibraryAuthorizationStatus(status)
            }
        }
    }
    
    func presentRestrictedAccessWarningAlert() {
        let alertController = UIAlertController(title: "Permission to access photos has not been given. Please allow access in device settings.", message: nil, preferredStyle: .alert)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        alertController.addAction(.init(title: "Settings", style: .default, handler: { _ in
            let settingsPathURL = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsPathURL)
        }))
        present(alertController, animated: true)
    }
    
    func addNotificationObservers() {
        didBecomeActiveNotificationObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkPhotoLibraryAccessOnBecomeActive()
        }
    }
    
    func checkPhotoLibraryAccessOnBecomeActive() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined, .restricted, .denied:
            break
        case .authorized, .limited:
            onAccessGranted?()
        default:
            break
        }
    }
    
    func removeNotificationObservers() {
        guard let didBecomeActiveNotificationObserver = didBecomeActiveNotificationObserver else { return }
        NotificationCenter.default.removeObserver(didBecomeActiveNotificationObserver)
    }
}
