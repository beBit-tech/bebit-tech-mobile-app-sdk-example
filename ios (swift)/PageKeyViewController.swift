import OmniSegmentKit  // BeBit Tech analytics SDK for manual page tracking
import UIKit

class PageKeyViewController: UIViewController {
    // Create the floating input view
    let floatingInputView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 8
        return view
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter page key..."
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Ensure the background is visible
        setupFloatingInputView()

        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

    func setupFloatingInputView() {
        // Add the floating input view to the main view
        view.addSubview(floatingInputView)
        floatingInputView.addSubview(textField)
        floatingInputView.addSubview(sendButton)

        // Set up constraints for the floating input view
        NSLayoutConstraint.activate([
            floatingInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            floatingInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            floatingInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingInputView.heightAnchor.constraint(equalToConstant: 50),
        ])

        // Set up constraints for the text field
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: floatingInputView.leadingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: floatingInputView.centerYAnchor),
            textField.heightAnchor.constraint(equalTo: floatingInputView.heightAnchor, constant: -16),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
        ])

        // Set up constraints for the send button
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: floatingInputView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: floatingInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
        ])
    }

    // Action method for the send button
    @objc func sendButtonTapped() {
        // OmniSegment SDK
        // Manually set current page for analytics tracking
        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
        OmniSegment.setCurrentPage(textField.text ?? "")
    }
}
