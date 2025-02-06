import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var topLeadingLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingIndicator()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticService()
        
        questionFactory?.loadData()
        
        topLeadingLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel?.font =  UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font =  UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
        showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.ypWhite.cgColor
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers += isCorrect ? 1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            alertPresenter = AlertPresenter(delegate: self)
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let correctAnswersInBestGame = statisticService?.bestGame.correct else { return }
            guard let bestGameDate = statisticService?.bestGame.date else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            
            let title = "Этот раунд окончен!"
            let message =
            """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            \nКоличество сыгранных квизов: \(gamesCount)
            \nРекорд: \(correctAnswersInBestGame)/\(questionsAmount) \(bestGameDate.dateTimeString)
            \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            let buttonText = "Сыграть ещё раз"
            
            let alert = AlertModel(title: title, message: message, buttonText: buttonText, completion: startAgain)
            
            alertPresenter?.showAlert(model: alert)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func startAgain() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        alertPresenter = AlertPresenter(delegate: self)
        guard let questionFactory = questionFactory else { return }
        let alert = AlertModel(title: "Ошибка",
                               message: "Что-то пошло не так",
                               buttonText: "Попробовать еще раз",
                               completion: questionFactory.loadData)
        
        alertPresenter?.showAlert(model: alert)
        // создайте и покажите алерт
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}
