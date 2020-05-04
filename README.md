# Obj2SceneKit
Parse .obj into SCNGeometry

Normally, it's possible to load .obj directly into SCNScene:

```let bundle = NSBundle.mainBundle()  
 let path = bundle.pathForResource("model", ofType: "obj")  
 let url = NSURL(fileURLWithPath: path!)  
 let asset = MDLAsset(URL: url)  
 let scene = SCNScene(MDLAsset: asset)
 ```
 
However, if you need to load only a part of the data (for instance, just vertices of texture coordinates), you can pase .obj data you need, see `FileParser.swift` and `FileHelper.swift`

The test project uses Swift lint as a CocoaPod. cd into Obj2SceneKit, run `pod install`
