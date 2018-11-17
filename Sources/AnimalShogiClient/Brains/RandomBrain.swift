import AnimalShogi

public class RandomBrain: Brain {
    public func handleBoardChange(summary: GameSummary, board: Board, sendMessage: (Message) -> Void) {
        let captured = summary.turn == .black ? board.blackCaptured : board.whiteCaptured

        if
            let kind = captured.randomElement(),
            let to = board.positions.filter({ board[$0] == nil }).randomElement() {
            sendMessage(.drop(turn: summary.turn, kind: kind, to: to))
            return
        }

        let moves = board.pieces
            .filter { _, piece in piece.turn == summary.turn }
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

        sendMessage(.move(turn: summary.turn, from: from, to: to, isPromoted: isPromoted))
    }
}
