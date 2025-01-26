//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Алексей Непряхин on 14.01.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
