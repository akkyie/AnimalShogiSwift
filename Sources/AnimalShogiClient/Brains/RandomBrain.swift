import AnimalShogi

public class RandomBrain: Brain {
    private var board = Board()
    private var isBlack: Bool = true
    private var capturedPieces: [PieceKind] = []

    public init(board: Board = Board()) {
        self.board = board
    }

    public func handleStateChange(to newState: State, from oldState: State?, sendMessage: (Message) -> Void) {
        switch (newState, oldState) {
        case let (.starting(_, _isBlack), _):
            isBlack = _isBlack
            sendMessage(.agree)
        case (.started, _) where isBlack == true: // game started and you are black
            thinkNext(sendMessage: sendMessage)
        case (.moved(_, !isBlack, let from, let to, let isPromoted), _): // opponent moved
            _ = board.move(from: from, to: to, isPromoted: isPromoted)
            thinkNext(sendMessage: sendMessage)
        case (.dropped(_, !isBlack, let kind, let to), _): // opponent moved
            _ = board.drop(kind: kind, to: to, isBlack: !isBlack)
            thinkNext(sendMessage: sendMessage)
        default:
            break
        }
    }

    private func thinkNext(sendMessage: (Message) -> Void) {
        if
            let captured = capturedPieces.popLast(),
            let dropTo = board.positions.filter({ board[$0] == nil }).randomElement() {
            board.drop(kind: captured, to: dropTo, isBlack: isBlack)
            sendMessage(.drop(kind: captured, to: dropTo, isBlack: isBlack))
            return
        }

        let moves = board.pieces
            .filter { _, piece in piece.isBlack == isBlack }
            .flatMap { from, piece in
                board.movablePoints(from: from).map { (piece, from, $0) }
            }

        guard case let (piece, from, to)? = moves.randomElement() else {
            preconditionFailure("no piece on the board")
        }

        let isPromoted: Bool
        if piece.promoted(on: to) != nil {
            isPromoted = Bool.random()
        } else {
            isPromoted = false
        }

        if let captured = board.move(from: from, to: to, isPromoted: isPromoted) {
            capturedPieces.append(captured.kind)
        }
        sendMessage(.move(from: from, to: to, isBlack: isBlack, isPromoted: isPromoted))
    }
}
