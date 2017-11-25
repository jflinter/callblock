//
//  CallDirectoryHandler.swift
//  BlockRegex
//
//  Created by Jack Flintermann on 11/17/17.
//  Copyright © 2017 Jack Flintermann. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
        if context.isIncremental {
//            addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
        } else {
            addAllBlockingPhoneNumbers(to: context)
        }

        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve all phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.
        let blockingRegexes = [
            "1401488****",
            "1847687****",
        ]
        let ranges: [(Int64, Int64)] = blockingRegexes.map { regex in
            let low = Int64(regex.replacingOccurrences(of: "*", with: "0"))!
            let high = Int64(regex.replacingOccurrences(of: "*", with: "9"))!
            return (low, high)
        }.sorted { a, b in
            a.0 < b.0
        }
        
        for range in ranges {
            for number in (range.0...range.1) {
                context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            }
        }
    }

//    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
//        // Retrieve any changes to the set of phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
//        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
//        let phoneNumbersToAdd: [CXCallDirectoryPhoneNumber] = [ 1_408_555_1234 ]
//        for phoneNumber in phoneNumbersToAdd {
//            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
//        }
//
//        let phoneNumbersToRemove: [CXCallDirectoryPhoneNumber] = [ 1_800_555_5555 ]
//        for phoneNumber in phoneNumbersToRemove {
//            context.removeBlockingEntry(withPhoneNumber: phoneNumber)
//        }
//
//        // Record the most-recently loaded set of blocking entries in data store for the next incremental load...
//    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
