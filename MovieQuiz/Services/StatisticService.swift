//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Алексей Непряхин on 21.01.2025.
//

import Foundation

class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case correctAnswersInBestGame
        case numberOfQuestionsInRound
        case dateOfBestGame
        case totalNumberOfQuestionsAsked
        case totalNumberOfCorrectAnswers
        case totalAccuracy
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswersInBestGame = storage.integer(forKey: Keys.correctAnswersInBestGame.rawValue)
            let numberOfQuestionsInRound = storage.integer(forKey: Keys.numberOfQuestionsInRound.rawValue)
            let dateOfBestGame = storage.object(forKey: Keys.dateOfBestGame.rawValue) as? Date ?? Date()
            return GameResult(correct: correctAnswersInBestGame, total: numberOfQuestionsInRound, date: dateOfBestGame)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correctAnswersInBestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.numberOfQuestionsInRound.rawValue)
            storage.set(newValue.date, forKey: Keys.dateOfBestGame.rawValue)
        }
    }
    
    var totalNumberOfQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalNumberOfQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalNumberOfQuestionsAsked.rawValue)
        }
    }
    
    var totalNumberOfCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalNumberOfCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalNumberOfCorrectAnswers.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            if totalNumberOfQuestionsAsked > 0 {
                let newValue = ((Double(totalNumberOfCorrectAnswers) / Double(totalNumberOfQuestionsAsked)) * 100)
                storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
            } else {
                storage.set(0, forKey: Keys.totalAccuracy.rawValue)
            }
            return storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        totalNumberOfQuestionsAsked += amount
        totalNumberOfCorrectAnswers += count
        gamesCount += 1
        let lastGame = GameResult(correct: count, total: amount, date: Date())
        if !bestGame.isBetterThan(lastGame) {
            bestGame = lastGame
        }
    }
    
    
}
