//
//  Score.swift
//  Breakout
//
//  Created by Peter Luo on 2020/8/21.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import Foundation

struct Score : Comparable, Codable {
    
    var name: String
    var value: Int
    
    static func ==(_ lhs: Score, _ rhs: Score) -> Bool {
        return lhs.value == rhs.value
    }
    
    static func >(_ lhs: Score, _ rhs: Score) -> Bool {
        return lhs.value > rhs.value
    }
    
    static func <(_ lhs: Score, _ rhs: Score) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func >=(_ lhs: Score, _ rhs: Score) -> Bool {
        return lhs.value >= rhs.value
    }
    
    static func <=(_ lhs: Score, _ rhs: Score) -> Bool {
        return lhs.value <= rhs.value
    }
    
}

class ScoreBoard: NSObject {
    
    var scores: [Score] {
        didSet {
            self.saveToUserDefaults()
        }
    }
    
    override init() {
        scores = [Score]()
    }
    
    static var shared : ScoreBoard {
        return sharedScoreBoard
    }
    
    func insert(_ score: Score) {
        guard scores.count >= 10 else {
            scores.append(score)
            return
        }
        if score >= scores.last! {
            scores.append(score)
            scores.sort()
            scores.removeLast()
        }
    }
    
    func saveToUserDefaults() {
        for i in 0..<10 {
            guard i < scores.count else {
                for indexToRemove in i..<10 {
                    UserDefaults.standard.removeObject(forKey: "HighScore_\(indexToRemove)")
                }
                return
            }
            let score = scores[i]
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(score) {
                UserDefaults.standard.set(encoded, forKey: "HighScore_\(i)")
            }
        }
    }
    
    func loadFromUserDefaultsIfAvailible() {
        for i in 0..<10 {
            let decoder = JSONDecoder()
            guard let data = UserDefaults.standard.object(forKey: "HighScore_\(i)") as? Data else { return }
            if let loadedScore = try? decoder.decode(Score.self, from: data) {
                scores.append(loadedScore)
            }
        }
    }
    
}

fileprivate let sharedScoreBoard = ScoreBoard()
