import Vapor

func routes(_ app: Application) throws {    
    let openURLController = OpenURLController()
    try app.register(collection: openURLController)
    
    let recordVideoController = RecordVideoController()
    try app.register(collection: recordVideoController)
    
    let sendPNContoller = SendPNController()
    try app.register(collection: sendPNContoller)
}
