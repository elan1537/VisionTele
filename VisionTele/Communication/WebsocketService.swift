import Foundation
import simd

class WebsocketService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    @Published var url: URL?
    

    @Published var robotJoints: [Float] = [0, 0, 0, 0, 0, 0]
    @Published var tcpPos = SIMD3<Float>(0, 0, 0)
    @Published var tcpRot: [Float] = []
    @Published var isConnencted: Bool = false
    
    init(url: URL) {
        self.url = url
        connect()
        print("connect?")
    }
    
    func setUrl(url: URL) {
        self.url = url
        connect()
    }
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: self.url!)
        webSocketTask?.resume()
        receiveMessage()
        setupHeartbeat()
        self.isConnencted = true
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        self.isConnencted = false
    }
    
    private func reconnect() {
        disconnect()
        connect()
    }
    
    private func setupHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.webSocketTask?.sendPing { error in
                if let error = error {
                    print("Ping failed: \(error.localizedDescription)")
                    self?.reconnect()
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                default: break
                }
                self.receiveMessage()
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
            
            let q1 = Float(truncating: jsonObject["q1"] as! NSNumber)
            let q2 = Float(truncating: jsonObject["q2"] as! NSNumber)
            let q3 = Float(truncating: jsonObject["q3"] as! NSNumber)
            let q4 = Float(truncating: jsonObject["q4"] as! NSNumber)
            let q5 = Float(truncating: jsonObject["q5"] as! NSNumber)
            let q6 = Float(truncating: jsonObject["q6"] as! NSNumber)
            let x  = Float(truncating: jsonObject["x"]  as! NSNumber)
            let y  = Float(truncating: jsonObject["y"]  as! NSNumber)
            let z  = Float(truncating: jsonObject["z"]  as! NSNumber)
            let ax = Float(truncating: jsonObject["ax"] as! NSNumber)
            let ay = Float(truncating: jsonObject["ay"] as! NSNumber)
            let az = Float(truncating: jsonObject["az"] as! NSNumber)
            
            DispatchQueue.main.async {
                self.robotJoints = [
                    q1 *         .pi / 180.0,
                    (q2 + 180) * .pi / 180.0,
                    q3 *         .pi / 180.0,
                    (q4 + 180) * .pi / 180.0,
                    q5 *         .pi / 180.0,
                    q6 *         .pi / 180.0
                ]
                self.tcpPos = [x, y, z]
                self.tcpRot = [ax, ay, az]
            }
        }
    }
    
    func sendVirtualTCP(position: SIMD3<Float>) {
        let jsonMessage: [String: Any] = [
            "tcp_pos": ["x": position.x, "y": position.y, "z":position.z]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonMessage, options: []) else {
            print("Error: Unable to serialize subscription message to JSON")
            return
        }
        
        webSocketTask?.send(.data(jsonData)) { error in
            if let error = error {
                print("ERror in sending message: \(error)")
            }
        }
    }
}
