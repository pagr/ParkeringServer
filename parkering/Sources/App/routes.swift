import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

//    app.post("upload") { (req) -> String in
//        print("UPLOADING")
//        req.body.collect().whenComplete { (result) in
//            switch result {
//            case .success(let bytesBuffer):
//                guard var bytesBuffer = bytesBuffer else { print("oh noes, no data"); return }
//                let bytes = bytesBuffer.readableBytes
//                let data = bytesBuffer.readData(length: bytes)
//                print("Writing data \(bytes)")
//                do {
//                    try data?.write(to: URL(string: "file:///Users/paul/Desktop/upload/image.jpg")!)
//                } catch {
//                    let tmp = error
//                    print(tmp)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//        return ""
//    }

    app.post("upload") { req -> EventLoopFuture<String> in
        struct Input: Content {
            var file: File
        }
        let input = try req.content.decode(Input.self)

        let path = "/Users/paul/Desktop/upload/\(input.file.filename)"
        print("Path: \(path)")
        return req.application.fileio.openFile(path: path,
                                               mode: .write,
                                               flags: .allowFileCreation(posixMode: 0x744),
                                               eventLoop: req.eventLoop)
            .flatMap { handle in
                req.application.fileio.write(fileHandle: handle,
                                             buffer: input.file.data,
                                             eventLoop: req.eventLoop)
                    .flatMapThrowing { _ in
                        try handle.close()
                        return input.file.filename
                    }
            }
    }


//    try app.register(collection: TodoController())
}
