import UIKit

class DrawingView: UIView {
    private var path = UIBezierPath()
    private var points = [CGPoint]()
    private var strokes = [(path: UIBezierPath, color: UIColor, width: CGFloat, isEraser: Bool)]()
    var currentColor: UIColor = .black
    var lineWidth: CGFloat = 5.0
    var isEraserEnabled = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isMultipleTouchEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        points.append(point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        points.append(currentPoint)

        if points.count >= 4 {
            let controlPoint1 = midPoint(points[0], points[1])
            let controlPoint2 = midPoint(points[1], points[2])
            let endPoint = midPoint(points[2], points[3])

            path.move(to: controlPoint1)
            path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)

            points.removeFirst(2)
        }
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        strokes.append((
            path: path.copy() as! UIBezierPath,
            color: currentColor,
            width: lineWidth,
            isEraser: isEraserEnabled
        ))
        path.removeAllPoints()
        points.removeAll()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        for stroke in strokes {
            stroke.color.setStroke()
            stroke.path.lineWidth = stroke.width
            stroke.path.lineCapStyle = .round
            stroke.path.lineJoinStyle = .round

            if stroke.isEraser {
                stroke.path.stroke(with: .clear, alpha: 1.0)
            } else {
                stroke.path.stroke()
            }
        }

        if !path.isEmpty {
            currentColor.setStroke()
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            if isEraserEnabled {
                path.stroke(with: .clear, alpha: 1.0)
            } else {
                path.stroke()
            }
        }
    }

    func clear() {
        strokes.removeAll()
        path.removeAllPoints()
        points.removeAll()
        setNeedsDisplay()
    }

    private func midPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
}

class ViewController: UIViewController {
    private let drawingView = DrawingView()
    private let colorPicker = UIColorWell()
    private let widthSlider = UISlider()
    private let eraserButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        drawingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawingView)

        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.setValue("Цвет", forKey: "title")
        colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        view.addSubview(colorPicker)

        widthSlider.translatesAutoresizingMaskIntoConstraints = false
        widthSlider.minimumValue = 1
        widthSlider.maximumValue = 20
        widthSlider.value = 5
        widthSlider.addTarget(self, action: #selector(widthChanged), for: .valueChanged)
        view.addSubview(widthSlider)

        eraserButton.translatesAutoresizingMaskIntoConstraints = false
        eraserButton.setTitle("Ластик", for: .normal)
        eraserButton.addTarget(self, action: #selector(toggleEraser), for: .touchUpInside)
        view.addSubview(eraserButton)

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.addTarget(self, action: #selector(clearDrawing), for: .touchUpInside)
        view.addSubview(clearButton)

        setupConstraints()
    }

    @objc private func colorChanged() {
        drawingView.currentColor = colorPicker.selectedColor ?? .black
        drawingView.isEraserEnabled = false
        eraserButton.isSelected = false
        eraserButton.backgroundColor = .clear
        eraserButton.setTitleColor(.systemBlue, for: .normal)
    }

    @objc private func widthChanged() {
        drawingView.lineWidth = CGFloat(widthSlider.value)
    }

    @objc private func toggleEraser() {
        drawingView.isEraserEnabled.toggle()
        eraserButton.isSelected = drawingView.isEraserEnabled
        if drawingView.isEraserEnabled {
            eraserButton.backgroundColor = .systemBlue
            eraserButton.setTitleColor(.white, for: .normal)
        } else {
            eraserButton.backgroundColor = .clear
            eraserButton.setTitleColor(.systemBlue, for: .normal)
        }
    }

    @objc private func clearDrawing() {
        drawingView.clear()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            drawingView.bottomAnchor.constraint(equalTo: colorPicker.topAnchor, constant: -8),

            colorPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            colorPicker.centerYAnchor.constraint(equalTo: widthSlider.centerYAnchor),

            widthSlider.leadingAnchor.constraint(equalTo: colorPicker.trailingAnchor, constant: 16),
            widthSlider.trailingAnchor.constraint(equalTo: eraserButton.leadingAnchor, constant: -16),
            widthSlider.centerYAnchor.constraint(equalTo: eraserButton.centerYAnchor),
            widthSlider.heightAnchor.constraint(equalToConstant: 30),

            eraserButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -16),
            eraserButton.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor),

            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            clearButton.topAnchor.constraint(equalTo: drawingView.bottomAnchor, constant: 16),
            clearButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
