import AnimalShogi

public class RandomBrain: Brain {
    private var board = Board()
    private var isBlack: Bool = true

    public init(board: Board = Board()) {
        self.board = board
    }

    public func handleStateChange(to newState: State, from oldState: State?, sendMessage: (Message) -> Void) {
        switch (newState, oldState) {
        case let (.starting(_, _isBlack), _):
            isBlack = _isBlack
            sendMessage(.agree)
        case (.started, _) where isBlack == true: // game started and you are black
            next(sendMessage: sendMessage)
        case (.moved(_, !isBlack, let from, let to, let isPromoted), _): // opponent moved
            board.move(from: from, to: to, isPromoted: isPromoted)
            next(sendMessage: sendMessage)
        default:
            break
        }
    }

    private func next(sendMessage: (Message) -> Void) {
        let moves = board.pieces
            .filter { _, piece in piece.isBlack == isBlack }
            .flatMap { from, _ in
                board.movablePoints(from: from).map { to in (from, to) }
        }
        let randomIndex = Int.random(in: moves.indices)
        let (from, to) = moves[randomIndex]
        var isPromoted = false
        if board[from]!.promoted(on: to) != nil {
            isPromoted = Bool.random()
        }

        board.move(from: from, to: to, isPromoted: isPromoted)
        sendMessage(.move(from: from, to: to, isBlack: isBlack, isPromoted: isPromoted))
    }
}
