//
//  MatchServiceProtocol.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/29.
//

protocol MatchServiceProtocol {
    func matchStream(uid: String) -> AsyncThrowingStream<[Match], Error>
}
