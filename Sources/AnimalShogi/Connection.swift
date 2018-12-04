import Foundation

public enum Result {
    case data(Data)
    case error(Error)
}

public protocol Connection: class {
    typealias Handler = (Result) -> Void

    var handler: Handler? { get set }

    func start()
    func cancel()
    func send(data: Data)
}
