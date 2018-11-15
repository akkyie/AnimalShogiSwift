public protocol Brain {
    typealias SendMessage = (Message) -> Void
    func handleStateChange(to newState: State, from oldState: State?, sendMessage: SendMessage)
}
