import UIKit

struct ErrorModel {
    let message: String
    let actionText: String
    let action: () -> Void
    
    // Опциональные свойства для второй кнопки
    let secondaryActionText: String?
    let secondaryAction: (() -> Void)?
    
    // Инициализатор для совместимости с существующим кодом
    init(message: String, actionText: String, action: @escaping () -> Void) {
        self.message = message
        self.actionText = actionText
        self.action = action
        self.secondaryActionText = nil
        self.secondaryAction = nil
    }
    
    // Новый инициализатор для использования с двумя кнопками
    init(
        message: String,
        actionText: String,
        action: @escaping () -> Void,
        secondaryActionText: String?,
        secondaryAction: (() -> Void)?
    ) {
        self.message = message
        self.actionText = actionText
        self.action = action
        self.secondaryActionText = secondaryActionText
        self.secondaryAction = secondaryAction
    }
}

protocol ErrorView {
    func showError(_ model: ErrorModel)
}

extension ErrorView where Self: UIViewController {
    
    func showError(_ model: ErrorModel) {
        let title = NSLocalizedString("Error.title", comment: "")
        let alert = UIAlertController(
            title: title,
            message: model.message,
            preferredStyle: .alert
        )
        
        // Основная кнопка действия
        let primaryAction = UIAlertAction(
            title: model.actionText,
            style: .default
        ) { _ in
            model.action()
        }
        alert.addAction(primaryAction)
        
        // Вторая кнопка, если она предусмотрена
        if let secondaryText = model.secondaryActionText,
           let secondaryAction = model.secondaryAction {
            let secondaryAlertAction = UIAlertAction(
                title: secondaryText,
                style: .cancel
            ) { _ in
                secondaryAction()
            }
            alert.addAction(secondaryAlertAction)
        }
        
        present(alert, animated: true)
    }
}
