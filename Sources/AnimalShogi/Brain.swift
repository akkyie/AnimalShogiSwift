public protocol Brain {
    func handleBoardChange(summary: GameSummary, board: Board, sendMessage: (ClientMessage) -> Void)
}
