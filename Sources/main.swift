import UIKit

// MARK: - Models

struct CellPoint: Equatable {
    var x: Int
    var y: Int
}

struct Tetromino {
    var rotations: [[CellPoint]]
    var color: UIColor
    var rotation: Int = 0
    var origin: CellPoint = CellPoint(x: 3, y: 0)

    var blocks: [CellPoint] {
        rotations[rotation].map { CellPoint(x: origin.x + $0.x, y: origin.y + $0.y) }
    }

    mutating func rotateRight() {
        rotation = (rotation + 1) % rotations.count
    }
}

// MARK: - Game

final class TetrisGame {
    let width = 10
    let height = 20

    var board: [[UIColor?]] = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    var current = TetrisGame.randomPiece()
    var next = TetrisGame.randomPiece()
    var score = 0
    var lines = 0
    var gameOver = false

    var onChange: (() -> Void)?

    static func randomPiece() -> Tetromino {
        let pieces: [Tetromino] = [
            // I
            Tetromino(
                rotations: [
                    [CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 3, y: 1)],
                    [CellPoint(x: 2, y: 0), CellPoint(x: 2, y: 1), CellPoint(x: 2, y: 2), CellPoint(x: 2, y: 3)]
                ],
                color: .cyan
            ),
            // O
            Tetromino(
                rotations: [
                    [CellPoint(x: 1, y: 0), CellPoint(x: 2, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1)]
                ],
                color: .yellow
            ),
            // T
            Tetromino(
                rotations: [
                    [CellPoint(x: 1, y: 0), CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1)],
                    [CellPoint(x: 1, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 1, y: 2)],
                    [CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 1, y: 2)],
                    [CellPoint(x: 1, y: 0), CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 1, y: 2)]
                ],
                color: .purple
            ),
            // L
            Tetromino(
                rotations: [
                    [CellPoint(x: 0, y: 0), CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1)],
                    [CellPoint(x: 1, y: 0), CellPoint(x: 2, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 1, y: 2)],
                    [CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 2, y: 2)],
                    [CellPoint(x: 1, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 0, y: 2), CellPoint(x: 1, y: 2)]
                ],
                color: .orange
            ),
            // J
            Tetromino(
                rotations: [
                    [CellPoint(x: 2, y: 0), CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1)],
                    [CellPoint(x: 1, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 1, y: 2), CellPoint(x: 2, y: 2)],
                    [CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 0, y: 2)],
                    [CellPoint(x: 0, y: 0), CellPoint(x: 1, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 1, y: 2)]
                ],
                color: .blue
            ),
            // S
            Tetromino(
                rotations: [
                    [CellPoint(x: 1, y: 0), CellPoint(x: 2, y: 0), CellPoint(x: 0, y: 1), CellPoint(x: 1, y: 1)],
                    [CellPoint(x: 1, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 2, y: 2)]
                ],
                color: .green
            ),
            // Z
            Tetromino(
                rotations: [
                    [CellPoint(x: 0, y: 0), CellPoint(x: 1, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1)],
                    [CellPoint(x: 2, y: 0), CellPoint(x: 1, y: 1), CellPoint(x: 2, y: 1), CellPoint(x: 1, y: 2)]
                ],
                color: .red
            )
        ]

        var p = pieces.randomElement()!
        p.origin = CellPoint(x: 3, y: 0)
        p.rotation = 0
        return p
    }

    func startNewGame() {
        board = Array(repeating: Array(repeating: nil, count: width), count: height)
        score = 0
        lines = 0
        gameOver = false
        current = TetrisGame.randomPiece()
        next = TetrisGame.randomPiece()

        if !isValid(current) {
            gameOver = true
        }

        onChange?()
    }

    func isValid(_ piece: Tetromino) -> Bool {
        for b in piece.blocks {
            if b.x < 0 || b.x >= width || b.y < 0 || b.y >= height {
                return false
            }
            if board[b.y][b.x] != nil {
                return false
            }
        }
        return true
    }

    func move(dx: Int, dy: Int) -> Bool {
        guard !gameOver else { return false }
        var test = current
        test.origin.x += dx
        test.origin.y += dy
        if isValid(test) {
            current = test
            onChange?()
            return true
        }
        return false
    }

    func rotate() {
        guard !gameOver else { return }
        var test = current
        test.rotateRight()

        if isValid(test) {
            current = test
            onChange?()
            return
        }

        for kick in [-1, 1, -2, 2] {
            var shifted = test
            shifted.origin.x += kick
            if isValid(shifted) {
                current = shifted
                onChange?()
                return
            }
        }
    }

    func stepDown() {
        guard !gameOver else { return }
        if !move(dx: 0, dy: 1) {
            lockPiece()
        }
    }

    func hardDrop() {
        guard !gameOver else { return }
        while move(dx: 0, dy: 1) {}
        lockPiece()
    }

    func lockPiece() {
        for b in current.blocks {
            if b.y >= 0 && b.y < height && b.x >= 0 && b.x < width {
                board[b.y][b.x] = current.color
            }
        }

        clearLines()

        current = next
        current.origin = CellPoint(x: 3, y: 0)
        current.rotation = 0
        next = TetrisGame.randomPiece()

        if !isValid(current) {
            gameOver = true
        }

        onChange?()
    }

    func clearLines() {
        var newBoard: [[UIColor?]] = []

        for row in board {
            let full = row.allSatisfy { $0 != nil }
            if !full {
                newBoard.append(row)
            }
        }

        let removed = height - newBoard.count
        if removed > 0 {
            for _ in 0..<removed {
                newBoard.insert(Array(repeating: nil, count: width), at: 0)
            }
            board = newBoard
            lines += removed

            switch removed {
            case 1: score += 100
            case 2: score += 300
            case 3: score += 500
            case 4: score += 800
            default: break
            }
        }
    }

    func colorAt(x: Int, y: Int) -> UIColor? {
        if let c = board[y][x] { return c }
        for b in current.blocks where b.x == x && b.y == y {
            return current.color
        }
        return nil
    }
}

// MARK: - Board View

final class BoardView: UIView {
    let game: TetrisGame

    init(game: TetrisGame) {
        self.game = game
        super.init(frame: .zero)
        backgroundColor = .black
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(rect)

        let cellW = rect.width / CGFloat(game.width)
        let cellH = rect.height / CGFloat(game.height)

        for y in 0..<game.height {
            for x in 0..<game.width {
                let r = CGRect(
                    x: CGFloat(x) * cellW,
                    y: CGFloat(y) * cellH,
                    width: cellW,
                    height: cellH
                )

                if let color = game.colorAt(x: x, y: y) {
                    ctx.setFillColor(color.cgColor)
                    ctx.fill(r.insetBy(dx: 1, dy: 1))
                } else {
                    ctx.setStrokeColor(UIColor.darkGray.cgColor)
                    ctx.stroke(r.insetBy(dx: 0.5, dy: 0.5))
                }
            }
        }
    }
}

// MARK: - View Controller

final class GameViewController: UIViewController {
    let game = TetrisGame()
    var boardView: BoardView!
    var timer: Timer?

    let scoreLabel = UILabel()
    let linesLabel = UILabel()
    let statusLabel = UILabel()

    let leftButton = UIButton(type: .system)
    let rightButton = UIButton(type: .system)
    let downButton = UIButton(type: .system)
    let rotateButton = UIButton(type: .system)
    let dropButton = UIButton(type: .system)
    let restartButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        boardView = BoardView(game: game)
        boardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(boardView)

        setupLabel(scoreLabel, size: 22)
        setupLabel(linesLabel, size: 18)
        setupLabel(statusLabel, size: 22)
        statusLabel.textColor = .red
        statusLabel.numberOfLines = 0

        setupButton(leftButton, "◀")
        setupButton(rightButton, "▶")
        setupButton(downButton, "▼")
        setupButton(rotateButton, "⟳")
        setupButton(dropButton, "DROP")
        setupButton(restartButton, "RESTART")

        let row1 = UIStackView(arrangedSubviews: [leftButton, downButton, rightButton])
        row1.axis = .horizontal
        row1.spacing = 12
        row1.distribution = .fillEqually
        row1.translatesAutoresizingMaskIntoConstraints = false

        let row2 = UIStackView(arrangedSubviews: [rotateButton, dropButton, restartButton])
        row2.axis = .horizontal
        row2.spacing = 12
        row2.distribution = .fillEqually
        row2.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(row1)
        view.addSubview(row2)

        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            linesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 6),
            linesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            linesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            boardView.topAnchor.constraint(equalTo: linesLabel.bottomAnchor, constant: 12),
            boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor, multiplier: 2.0),

            statusLabel.centerXAnchor.constraint(equalTo: boardView.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: boardView.centerYAnchor),

            row1.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 20),
            row1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            row1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            row1.heightAnchor.constraint(equalToConstant: 56),

            row2.topAnchor.constraint(equalTo: row1.bottomAnchor, constant: 12),
            row2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            row2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            row2.heightAnchor.constraint(equalToConstant: 56)
        ])

        leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        downButton.addTarget(self, action: #selector(moveDown), for: .touchUpInside)
        rotateButton.addTarget(self, action: #selector(rotatePiece), for: .touchUpInside)
        dropButton.addTarget(self, action: #selector(dropPiece), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        boardView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        boardView.addGestureRecognizer(swipeRight)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        boardView.addGestureRecognizer(swipeDown)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        boardView.addGestureRecognizer(tap)

        boardView.isUserInteractionEnabled = true

        game.onChange = { [weak self] in
            self?.updateUI()
        }

        game.startNewGame()
        startTimer()
    }

    func setupLabel(_ label: UILabel, size: CGFloat) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: size, weight: .bold)
        view.addSubview(label)
    }

    func setupButton(_ button: UIButton, _ title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        button.layer.cornerRadius = 12
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }

    func updateUI() {
        scoreLabel.text = "SCORE: \(game.score)"
        linesLabel.text = "LINES: \(game.lines)"
        statusLabel.text = game.gameOver ? "GAME OVER" : ""
        boardView.setNeedsDisplay()
    }

    @objc func timerTick() {
        if !game.gameOver {
            game.stepDown()
        }
    }

    @objc func moveLeft() {
        _ = game.move(dx: -1, dy: 0)
    }

    @objc func moveRight() {
        _ = game.move(dx: 1, dy: 0)
    }

    @objc func moveDown() {
        game.stepDown()
    }

    @objc func rotatePiece() {
        game.rotate()
    }

    @objc func dropPiece() {
        game.hardDrop()
    }

    @objc func restartGame() {
        game.startNewGame()
    }

    @objc func handleSwipeLeft() {
        _ = game.move(dx: -1, dy: 0)
    }

    @objc func handleSwipeRight() {
        _ = game.move(dx: 1, dy: 0)
    }

    @objc func handleSwipeDown() {
        game.hardDrop()
    }

    @objc func handleTap() {
        game.rotate()
    }
}

// MARK: - App Delegate

final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = GameViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

// MARK: - Main App

@main
final class MainApplication: UIApplication, UIApplicationDelegate {
    private static var appDelegate = AppDelegate()

    override init() {
        super.init()
        delegate = Self.appDelegate
    }
}
