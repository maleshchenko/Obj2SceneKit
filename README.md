# Obj2SceneKit
Parse .obj into SCNGeometry

Normally, it's possible to load .obj directly into SCNScene:

```let bundle = NSBundle.mainBundle()  
 let path = bundle.pathForResource("model", ofType: "obj")  
 let url = NSURL(fileURLWithPath: path!)  
 let asset = MDLAsset(URL: url)  
 let scene = SCNScene(MDLAsset: asset)
 ```
 
However, if you need to load only a part of the data (for instance, just vertices or texture coordinates), you can pase .obj data you need, see `FileParser.swift` and `FileHelper.swift`

The test project uses SwiftLint as a CocoaPod. cd into Obj2SceneKit, run `pod install`

# TODO:

1. Possible errors handling (faulty or empty .obj file)
2. Negative indices handling
3. Initialize CGPoints from regular Floats without type casting
4. Remove bridging from FileHelper
5. Remove spotlightNodeSpot force unwraps
6. Make sure normals and polygons are assembled correctly
7. Improve triangulation
