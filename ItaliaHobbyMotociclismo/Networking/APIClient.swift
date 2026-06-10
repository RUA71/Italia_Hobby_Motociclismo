import Foundation

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(Int, String?)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "L'URL della richiesta non è valido."
        case .noData:
            return "Nessun dato ricevuto dal server."
        case .decodingFailed(let error):
            return "Errore di decodifica: \(error.localizedDescription)"
        case .serverError(let code, let msg):
            return "Errore del server (\(code)): \(msg ?? "sconosciuto")"
        case .unauthorized:
            return "Accesso non autorizzato. Effettua il login."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - API Endpoints

enum APIEndpoint {
    static let baseURL = "https://api.italiahobbymotociclismo.it"

    case getEvents(userId: String?)
    case subscribeEvent
    case unsubscribeEvent
    case getChat(eventId: String, userId: String)
    case postMessage(eventId: String)
    case registerUser
    case getUser(userId: String)

    var path: String {
        switch self {
        case .getEvents:                  return "/events"
        case .subscribeEvent:             return "/events/subscribe"
        case .unsubscribeEvent:           return "/events/unsubscribe"
        case .getChat(let id, _):         return "/events/\(id)/chat"
        case .postMessage(let id):        return "/events/\(id)/chat"
        case .registerUser:               return "/user/register"
        case .getUser(let id):            return "/user/\(id)"
        }
    }

    /// Returns the full URL including any required query parameters.
    var url: URL? {
        var components = URLComponents(string: APIEndpoint.baseURL + path)
        switch self {
        case .getEvents(let userId):
            if let userId {
                components?.queryItems = [URLQueryItem(name: "user_id", value: userId)]
            }
        case .getChat(_, let userId):
            components?.queryItems = [URLQueryItem(name: "user_id", value: userId)]
        default:
            break
        }
        return components?.url
    }

    var httpMethod: String {
        switch self {
        case .getEvents, .getChat, .getUser:
            return "GET"
        case .subscribeEvent, .unsubscribeEvent, .postMessage, .registerUser:
            return "POST"
        }
    }
}

// MARK: - API Client

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Generic Request

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        body: (some Encodable)? = nil as EmptyBody?
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            let msg = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(httpResponse.statusCode, msg)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    /// Performs a request that expects no response body.
    func requestEmpty(
        endpoint: APIEndpoint,
        body: (some Encodable)? = nil as EmptyBody?
    ) async throws {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            let msg = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(httpResponse.statusCode, msg)
        }
    }
}

// Used as a default type parameter when no body is needed.
private struct EmptyBody: Encodable {}
