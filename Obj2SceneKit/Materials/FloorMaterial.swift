//
//  FloorMaterial.swift
//  Obj2SceneKit
//
//  Created by Mykola Aleshchenko on 5/3/20.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import SceneKit

final class FloorMaterial: SCNMaterial {
    override init() {
        super.init()
        
        diffuse.contents = UIImage(named: "floor")
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
        
        normal.contents = UIColor.lightGray
        normal.intensity = 0.4
        
        selfIllumination.contents = UIColor.white
        selfIllumination.intensity = 0.3
        
        ambient.contents = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1)
        specular.contents = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
