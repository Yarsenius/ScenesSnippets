import Igis
import Scenes

public class AutoResizingScene : Scene, WindowResizeHandler {

    private let clip = Clip()
    private let viewportPath : Path
    private var windowSize : Size?

    public let localViewportRect : Rect
    public private(set) var globalViewportRect : Rect

    public init(size:Size, name:String = "AutoResizingScene") {
        localViewportRect = Rect(topLeft:Point(), size:size)
        globalViewportRect = localViewportRect
        
        viewportPath = Path(fillMode:.clear)
        viewportPath.rect(localViewportRect)
        
        super.init(name:name)
    }
    
    public final override func preSetup(canvasSize:Size, canvas:Canvas) {
        preViewportSetup(canvasSize:canvasSize, canvas:canvas)
        dispatcher.registerWindowResizeHandler(handler:self)
        windowSize = canvas.canvasSize
        postViewportSetup(canvasSize:canvasSize, canvas:canvas)
    }    

    public final override func preCalculate(canvas:Canvas) {
        preViewportCalculate(canvas:canvas)
        if let windowSize = windowSize {
            canvas.canvasSetSize(size:windowSize)

            let canvasWidth = Double(windowSize.width)
            let canvasHeight = Double(windowSize.height)            
            let viewportWidth = Double(localViewportRect.size.width)
            let viewportHeight = Double(localViewportRect.size.height)
            
            let offsetTransform : Transform
            let scaleTransform : Transform
            
            if canvasWidth / canvasHeight >= viewportWidth / viewportHeight {
                let scale = canvasHeight / viewportHeight
                let offset = (canvasWidth - viewportWidth * scale) * 0.5
                offsetTransform = Transform(translate:DoublePoint(x:offset, y:0), mode:.fromIdentity)
                scaleTransform = Transform(scale:DoublePoint(x:scale, y:scale), mode:.fromCurrent)
                globalViewportRect = Rect(
                  topLeft:Point(x:Int(offset.rounded()), y:0),
                  size:Size(width:Int((scale * viewportWidth).rounded()), height:windowSize.height))
            } else {
                let scale = canvasWidth / viewportWidth
                let offset = (canvasHeight - viewportHeight * scale) * 0.5
                offsetTransform = Transform(translate:DoublePoint(x:0, y:offset), mode:.fromIdentity)
                scaleTransform = Transform(scale:DoublePoint(x:scale, y:scale), mode:.fromCurrent)
                globalViewportRect = Rect(
                  topLeft:Point(x:0, y:Int(offset.rounded())),
                  size:Size(width:windowSize.width, height:Int((scale * viewportHeight).rounded())))
            }
            
            canvas.render(offsetTransform, scaleTransform, viewportPath, clip)
            self.windowSize = nil
        }
        postViewportCalculate(canvas:canvas)
    }
    
    public final override func postTeardown() {
        preViewportTeardown()
        dispatcher.unregisterWindowResizeHandler(handler:self)
        postViewportTeardown()
    }

    public final func onWindowResize(size:Size) {
        windowSize = size
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    public func local(fromGlobal:Point) -> Point {
        let scaleX = Double(fromGlobal.x - globalViewportRect.left) / Double(globalViewportRect.size.width)
        let scaleY = Double(fromGlobal.y - globalViewportRect.top) / Double(globalViewportRect.size.height)
        
        return Point(x:Int((scaleX * Double(localViewportRect.size.width)).rounded()) + localViewportRect.left,
                     y:Int((scaleY * Double(localViewportRect.size.height)).rounded()) + localViewportRect.top)
    }

    public func global(fromLocal:Point) -> Point {
        let scaleX = Double(fromLocal.x - localViewportRect.left) / Double(localViewportRect.size.width)
        let scaleY = Double(fromLocal.y - localViewportRect.top) / Double(localViewportRect.size.height)
        
        return Point(x:Int((scaleX * Double(globalViewportRect.size.width)).rounded()) + globalViewportRect.left,
                     y:Int((scaleY * Double(globalViewportRect.size.height)).rounded()) + globalViewportRect.left)
    }

    // ********************************************************************************
    // API FOLLOWS
    // These functions may be over-ridden by descendant classes
    // ********************************************************************************
    
    public func preViewportSetup(canvasSize:Size, canvas:Canvas) {
    }

    public func postViewportSetup(canvasSize:Size, canvas:Canvas) {
    }

    public func preViewportCalculate(canvas:Canvas) {
    }

    public func postViewportCalculate(canvas:Canvas) {
    }
    
    public func preViewportTeardown() {
    }

    public func postViewportTeardown() {
    }
    
}
