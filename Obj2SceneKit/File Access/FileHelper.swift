//
//  FileHelper.swift
//  Obj2SceneKit
//
//  Created by Mykola Aleshchenko on 5/3/20.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import UIKit

final class FileHelper {
    let readBlockSize = 1024
    let lineSeparator = "\n".data(using: String.Encoding.utf8)

    private var fileHandle = FileHandle()
    private(set) var fileSize: UInt64 = 0
    private var readBuffer: NSMutableData!
    private var isEndOfFileReached = false

    // MARK: - Lifecycle

    init?(path: String) {
        if let fileDescriptor = FileHandle(forReadingAtPath: path) {
            fileHandle = fileDescriptor
            fileSize = fileHandle.seekToEndOfFile()
            fileHandle.seek(toFileOffset: 0)
            readBuffer = NSMutableData(capacity: readBlockSize)
        } else {
            readBuffer = nil
            return nil
        }
    }

    func closeFileDescriptor() {
        fileHandle.closeFile()
    }

    deinit {
        closeFileDescriptor()
    }

    // MARK: - Lines traversal

    func currentFilePosition() -> UInt64 {
        return fileHandle.offsetInFile
    }

    func nextLine() -> String? {
        if isEndOfFileReached {
            return nil
        }

        var readRange = readBuffer.range(of: lineSeparator ?? Data(),
                                         options: [],
                                         in: NSRange(location: 0, length: readBuffer.length))

        while readRange.location == NSNotFound {
            let currentBlock = fileHandle.readData(ofLength: readBlockSize)
            if currentBlock.isEmpty {
                isEndOfFileReached = true
                if readBuffer.length > 0 {
                    let line = String(data: readBuffer as Data,
                                      encoding: String.Encoding.utf8)
                    readBuffer.length = 0

                    return line as String?
                }

                return nil
            }
            readBuffer.append(currentBlock)
            readRange = readBuffer.range(of: lineSeparator ?? Data(),
                                         options: [],
                                         in: NSRange(location: 0, length: readBuffer.length))
        }

        let line = NSString(data: readBuffer.subdata(with: NSRange(location: 0, length: readRange.location)),
                            encoding: String.Encoding.utf8.rawValue)

        readBuffer.replaceBytes(in: NSRange(location: 0, length: readRange.location + readRange.length),
                                withBytes: nil, length: 0)

        return line as String?
    }
}
