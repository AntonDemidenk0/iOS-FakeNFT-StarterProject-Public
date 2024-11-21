//
//  MyNftStorage.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 15.11.24..
//

import Foundation

protocol MyNftStorage: AnyObject {
    func saveNft(_ nft: MyNFT)
    func getNft(with id: String) -> MyNFT?
}

final class MyNftStorageImpl: MyNftStorage {
    private var storage: [String: MyNFT] = [:]

    private let syncQueue = DispatchQueue(label: "sync-myNft-queue")

    func saveNft(_ nft: MyNFT) {
        syncQueue.async { [weak self] in
            self?.storage[nft.id] = nft
        }
    }

    func getNft(with id: String) -> MyNFT? {
        syncQueue.sync {
            storage[id]
        }
    }
}
