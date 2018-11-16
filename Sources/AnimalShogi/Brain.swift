public protocol Brain {
    func handleBoardChange(summary: GameSummary, board: Board, sendMessage: (Message) -> Void)
}
