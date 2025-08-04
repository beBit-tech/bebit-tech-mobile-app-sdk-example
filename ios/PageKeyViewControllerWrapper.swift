import SwiftUI
import UIKit

struct PageKeyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PageKeyViewController {
        return PageKeyViewController()
    }

    func updateUIViewController(_ uiViewController: PageKeyViewController, context: Context) {}
}
