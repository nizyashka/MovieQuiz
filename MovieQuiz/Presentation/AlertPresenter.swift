import UIKit

protocol AlertPresenterProtocol {
    var delegate: UIViewController? { get set }
    func showAlert(model: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
    var alert: UIAlertController?
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in model.completion() }
        
        guard let alert = self.alert else { return }
        alert.addAction(action)
        switch alert.title {
        case "Этот раунд окончен!":
            alert.view.accessibilityIdentifier = "gameResultAlert"
        case "Ошибка":
            alert.view.accessibilityIdentifier = "errorAlert"
        default:
            alert.view.accessibilityIdentifier = "alert"
        }
        
        guard let delegate = self.delegate else { return }
        delegate.present(alert, animated: true, completion: nil)
    }
}
