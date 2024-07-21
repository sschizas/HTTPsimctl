import Vapor

func routes(_ app: Application) throws {
    let openURLController = OpenURLController()
    try app.register(collection: openURLController)
    
    let recordVideoController = RecordVideoController()
    try app.register(collection: recordVideoController)
    
    let permissionsController = PermissionsController()
    try app.register(collection: permissionsController)
    
    let apnsController = APNSController()
    try app.register(collection: apnsController)
}
