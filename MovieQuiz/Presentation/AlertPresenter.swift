//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Алексей Непряхин on 15.01.2025.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    var delegate: UIViewController? { get set }
    func showAlert(model: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
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
        
        guard let delegate = self.delegate else { return }
        delegate.present(alert, animated: true, completion: nil)
    }
}
