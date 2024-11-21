import UIKit
import ProgressHUD

class ProgressHUD {
    
    // MARK: - Properties
    
    static var isShowing = false
    
    private static var window: UIWindow? {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
    }
    
    // MARK: - Methods
    
    static func show() {
        guard !isShowing else { return }
        isShowing = true
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        guard isShowing else { return }
        isShowing = false
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
