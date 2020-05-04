//
//  FileParser.swift
//  Obj2SceneKit
//
//  Created by Mykola Aleshchenko on 5/3/20.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import Foundation
import SceneKit

protocol FileParserDelegate: class {
    func didReachProgress(_ progress: Float)
}

private enum FileSections: String {
    case vertices           = "v"
    case normals            = "vn"
    case textureCoordinates = "vt"
    case faces              = "f"
}

final class FileParser {

    private var path: String = ""
    private weak var delegate: FileParserDelegate?

    convenience init(path: String, delegate: FileParserDelegate? = nil) {
        self.init()
        self.path = path
        self.delegate = delegate
    }

    func loadScene() -> SCNGeometry {
        var parsedGeometry = SCNGeometry()

        if let fileHelper = FileHelper(path: path) {
            var vertices = [SCNVector3]()
            var normals = [SCNVector3]()
            var textureCoordinates = [CGPoint]()
            var faceIndices = [CInt]()
            var geometryElements = [SCNGeometryElement]()

            let fileSize = Float(fileHelper.fileSize)

            while let line = fileHelper.nextLine() {
                let readableBlocks = line.components(separatedBy: .whitespaces).filter({ !$0.isEmpty })
                if !readableBlocks.isEmpty {
                    let section = FileSections(rawValue: readableBlocks[0])

                    switch section {
                    case .vertices:
                        // 3 floats for each vertex
                        if readableBlocks.count == 4 {
                            let x = Float(readableBlocks[1]) ?? 0
                            let y = Float(readableBlocks[2]) ?? 0
                            let z = Float(readableBlocks[3]) ?? 0
                            let vertex = SCNVector3Make(x, y, z)
                            vertices.append(vertex)
                        }

                    case .normals:
                        // 3 floats for each normal
                        if readableBlocks.count == 4 {
                            let x = Float(readableBlocks[1]) ?? 0
                            let y = Float(readableBlocks[2]) ?? 0
                            let z = Float(readableBlocks[3]) ?? 0
                            let normal = SCNVector3Make(x, y, z)
                            normals.append(normal)
                        }

                    case .textureCoordinates:
                        // Each coordinate is a CGPoint
                        let x = CGFloat(Float(readableBlocks[1]) ?? 0.0)
                        let y = CGFloat(Float(readableBlocks[2]) ?? 0.0)
                        let textureCoordinate = CGPoint(x: x, y: y)
                        textureCoordinates.append(textureCoordinate)

                    case .faces:
                        // Face indices
                        for i in 1..<readableBlocks.count {
                            let faces = readableBlocks[i].components(separatedBy: "/")

                            if i > 3 {
                                // Possible but not happening with the files we're using
                                // Adding indices[count - 3] to indices array
                                let index1 = faceIndices.count - 3
                                let index2 = faceIndices.count - 1
                                faceIndices.append(faceIndices[index1])

                                // Adding indices[count - 1] to indices array
                                faceIndices.append(faceIndices[index2])
                            }

                            // Adding face index to indices array
                            let index = CInt(faces[0]) ?? 0
                            faceIndices.append(index - 1)
                        }

                    default:
                        break
                    }
                }

                if let delegate = self.delegate {
                    let progress = Float(fileHelper.currentFilePosition()) / fileSize
                    delegate.didReachProgress(progress)
                }
            }

            fileHelper.closeFileDescriptor()

            let data = Data(bytes: faceIndices, count: MemoryLayout<CInt>.size * faceIndices.count)
            let element = SCNGeometryElement(data: data,
                                             primitiveType: .triangles,
                                             primitiveCount: faceIndices.count / 3,
                                             bytesPerIndex: MemoryLayout<CInt>.size)
            geometryElements.append(element)

            var sources = [SCNGeometrySource]()

            // Appending vertex array as a SCNGeometrySource
            let verticesSource = SCNGeometrySource(vertices: vertices)
            sources.append(verticesSource)

            // Appending normals array as a SCNGeometrySource
            let normalSource = SCNGeometrySource(normals: normals)
            sources.append(normalSource)

            // Appending texture coordinates as a SCNGeometrySource
            let textureCoords = SCNGeometrySource(textureCoordinates: textureCoordinates)
            sources.append(textureCoords)

            parsedGeometry = SCNGeometry(sources: sources, elements: geometryElements)
        }

        return parsedGeometry
    }
}
