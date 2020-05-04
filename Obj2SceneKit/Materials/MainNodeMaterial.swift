//
//  MainNodeMaterial.swift
//  Obj2SceneKit
//
//  Created by Mykola Aleshchenko on 5/3/20.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import SceneKit

final class MainNodeMaterial: SCNMaterial {

    convenience init(mainColor: UIColor) {
        self.init()
        selfIllumination.contents = mainColor
        selfIllumination.intensity = 0.5
    }

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
