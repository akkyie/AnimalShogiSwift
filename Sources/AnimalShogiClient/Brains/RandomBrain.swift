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
            let (from, to) = RandomBrain.thinkNext(board: board, isBlack: isBlack)
            board.move(from: from, to: to)
            sendMessage(.move(from: from, to: to, isBlack: isBlack))
        case (.moved(_, !isBlack, let from, let to), _): // opponent moved
            board.move(from: from, to: to)
            let (from, to) = RandomBrain.thinkNext(board: board, isBlack: isBlack)
            board.move(from: from, to: to)
            sendMessage(.move(from: from, to: to, isBlack: isBlack))
        default:
            break
        }
    }

    private static func thinkNext(board: Board, isBlack: Bool) -> (from: Position, to: Position) {
        let moves = board.pieces
            .filter { _, piece in piece.isBlack == isBlack }
            .flatMap { from, _ in
                board.movablePoints(from: from).map { to in (from, to) }
            }
        let randomIndex = Int.random(in: moves.indices)
        return moves[randomIndex]
    }
}
