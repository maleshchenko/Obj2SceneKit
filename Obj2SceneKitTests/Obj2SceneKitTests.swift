//
//  Obj2SceneKitTests.swift
//  Obj2SceneKitTests
//
//  Created by Mykola Aleshchenko on 5/3/20.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import XCTest
@testable import Obj2SceneKit

class SceneKitTestTests: XCTestCase {
    private let filePath = Bundle.main.path(forResource: "cube", ofType: "obj")
    private var parser = FileParser()

    override func setUp() {
        guard let path = self.filePath else {
            XCTFail("File not found")
            return
        }

        parser = FileParser(path: path)
    }

    func testParsing() {
        let geometry = parser.loadScene()
        XCTAssert(!geometry.sources.isEmpty, "parsed geometry sources must not be empty")
        XCTAssert(!geometry.elements.isEmpty, "parsed geometry must contain at least one element")
    }
}
