import Foundation
import Network

/// Extension이 규칙과 프로필 목록을 가져갈 수 있도록 localhost HTTP 서버를 제공합니다.
/// GET http://127.0.0.1:19384/rules
final class RulesServer {
    static let shared = RulesServer()

    private var listener: NWListener?
    private let port: NWEndpoint.Port = 19384

    func start() {
        do {
            listener = try NWListener(using: .tcp, on: port)
            listener?.newConnectionHandler = { [weak self] conn in
                self?.handleConnection(conn)
            }
            listener?.start(queue: .global(qos: .utility))
        } catch {
            print("[RulesServer] Failed to start: \(error)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleConnection(_ conn: NWConnection) {
        conn.start(queue: .global(qos: .utility))
        conn.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] _, _, _, _ in
            self?.sendResponse(conn)
        }
    }

    private func sendResponse(_ conn: NWConnection) {
        let rules = ConfigManager.shared.rules.filter(\.isEnabled)
        let profiles = ChromeProfileScanner.scan()

        let rulesJSON: [[String: Any]] = rules.map { rule in
            [
                "patternType": rule.patternType.rawValue,
                "pattern": rule.pattern,
                "chromeProfile": rule.chromeProfile,
                "shouldAsk": rule.shouldAsk,
            ]
        }

        let profilesJSON: [[String: String]] = profiles.map { profile in
            [
                "directory": profile.directory,
                "name": profile.name,
                "email": profile.email,
            ]
        }

        let payload: [String: Any] = [
            "rules": rulesJSON,
            "profiles": profilesJSON,
        ]

        let body = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data("{}".utf8)

        let header = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"

        var response = Data(header.utf8)
        response.append(body)

        conn.send(content: response, completion: .contentProcessed { _ in
            conn.cancel()
        })
    }
}
