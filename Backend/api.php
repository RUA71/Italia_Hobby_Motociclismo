<?php
/**
 * Italia Hobby Motociclismo — REST API
 * Hosted on Aruba.it — PHP 8.x + MySQL/MariaDB
 *
 * Database schema and routing for all app endpoints.
 */

// ---- Database connection ----
$host   = getenv('DB_HOST')   ?: 'localhost';
$dbname = getenv('DB_NAME')   ?: 'ihm_db';
$user   = getenv('DB_USER')   ?: 'ihm_user';
$pass   = getenv('DB_PASS')   ?: '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['data' => null, 'error' => 'Database connection failed']);
    exit;
}

// ---- Helpers ----

/**
 * All responses — success and error — share the same envelope:
 * { "data": <payload|null>, "error": <message|null> }
 */
function jsonResponse(mixed $data, int $status = 200): never {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['data' => $data, 'error' => null]);
    exit;
}

function jsonError(string $message, int $status = 400): never {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['data' => null, 'error' => $message]);
    exit;
}

function getBody(): array {
    return json_decode(file_get_contents('php://input'), true) ?? [];
}

function requireParams(array $body, array $keys): void {
    foreach ($keys as $key) {
        if (empty($body[$key])) {
            jsonError("Missing required field: $key");
        }
    }
}

/**
 * Verifies that the given user_id is subscribed to the given event_id.
 * Terminates with 403 if not subscribed.
 */
function requireSubscription(PDO $pdo, string $userId, string $eventId): void {
    $check = $pdo->prepare('SELECT 1 FROM subscriptions WHERE user_id = ? AND event_id = ?');
    $check->execute([$userId, $eventId]);
    if (!$check->fetch()) {
        jsonError('Not subscribed to this event', 403);
    }
}

// ---- Routing ----
$method = $_SERVER['REQUEST_METHOD'];
$path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
// Strip leading /api prefix if present
$path   = preg_replace('#^/api#', '', $path);

// GET /events
if ($method === 'GET' && $path === '/events') {
    $userId = $_GET['user_id'] ?? null;
    if ($userId) {
        $stmt = $pdo->prepare(
            'SELECT e.*, IF(s.user_id IS NOT NULL, 1, 0) AS is_subscribed,
             COUNT(DISTINCT s2.user_id) AS participant_count
             FROM events e
             LEFT JOIN subscriptions s  ON s.event_id = e.id AND s.user_id = ?
             LEFT JOIN subscriptions s2 ON s2.event_id = e.id
             GROUP BY e.id'
        );
        $stmt->execute([$userId]);
    } else {
        $stmt = $pdo->query(
            'SELECT e.*, 0 AS is_subscribed,
             COUNT(DISTINCT s.user_id) AS participant_count
             FROM events e
             LEFT JOIN subscriptions s ON s.event_id = e.id
             GROUP BY e.id'
        );
    }
    jsonResponse($stmt->fetchAll());
}

// POST /events/subscribe
if ($method === 'POST' && $path === '/events/subscribe') {
    $body = getBody();
    requireParams($body, ['user_id', 'event_id']);
    $stmt = $pdo->prepare(
        'INSERT IGNORE INTO subscriptions (user_id, event_id) VALUES (?, ?)'
    );
    $stmt->execute([$body['user_id'], $body['event_id']]);
    jsonResponse(['subscribed' => true]);
}

// POST /events/unsubscribe
if ($method === 'POST' && $path === '/events/unsubscribe') {
    $body = getBody();
    requireParams($body, ['user_id', 'event_id']);
    $stmt = $pdo->prepare(
        'DELETE FROM subscriptions WHERE user_id = ? AND event_id = ?'
    );
    $stmt->execute([$body['user_id'], $body['event_id']]);
    jsonResponse(['unsubscribed' => true]);
}

// GET /events/{id}/chat  — user_id is required to verify subscription
if ($method === 'GET' && preg_match('#^/events/([^/]+)/chat$#', $path, $m)) {
    $eventId = $m[1];
    $userId  = $_GET['user_id'] ?? null;
    if (!$userId) {
        jsonError('user_id is required', 400);
    }
    requireSubscription($pdo, $userId, $eventId);
    $stmt = $pdo->prepare(
        'SELECT m.*, u.nickname AS sender_nickname
         FROM messages m
         JOIN users u ON u.id = m.sender_id
         WHERE m.event_id = ?
         ORDER BY m.timestamp ASC'
    );
    $stmt->execute([$eventId]);
    jsonResponse($stmt->fetchAll());
}

// POST /events/{id}/chat  — verify subscription before posting
if ($method === 'POST' && preg_match('#^/events/([^/]+)/chat$#', $path, $m)) {
    $eventId = $m[1];
    $body    = getBody();
    requireParams($body, ['user_id', 'text']);
    requireSubscription($pdo, $body['user_id'], $eventId);
    $id = bin2hex(random_bytes(16));
    $stmt = $pdo->prepare(
        'INSERT INTO messages (id, event_id, sender_id, text, timestamp)
         VALUES (?, ?, ?, ?, NOW())'
    );
    $stmt->execute([$id, $eventId, $body['user_id'], $body['text']]);
    $fetch = $pdo->prepare(
        'SELECT m.*, u.nickname AS sender_nickname
         FROM messages m JOIN users u ON u.id = m.sender_id
         WHERE m.id = ?'
    );
    $fetch->execute([$id]);
    jsonResponse($fetch->fetch(), 201);
}

// POST /user/register
if ($method === 'POST' && $path === '/user/register') {
    $body = getBody();
    requireParams($body, ['nickname', 'city', 'country', 'motorbike_brand', 'motorbike_model']);
    $id = $body['id'] ?? bin2hex(random_bytes(16));
    $stmt = $pdo->prepare(
        'INSERT INTO users (id, nickname, name, surname, city, country, motorbike_brand, motorbike_model, motorbike_type)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE
           nickname       = VALUES(nickname),
           name           = VALUES(name),
           surname        = VALUES(surname),
           city           = VALUES(city),
           country        = VALUES(country),
           motorbike_brand = VALUES(motorbike_brand),
           motorbike_model = VALUES(motorbike_model),
           motorbike_type  = VALUES(motorbike_type)'
    );
    $stmt->execute([
        $id,
        $body['nickname'],
        $body['name']           ?? '',
        $body['surname']        ?? '',
        $body['city'],
        $body['country'],
        $body['motorbike_brand'],
        $body['motorbike_model'],
        $body['motorbike_type'] ?? '',
    ]);
    $fetch = $pdo->prepare('SELECT * FROM users WHERE id = ?');
    $fetch->execute([$id]);
    jsonResponse($fetch->fetch(), 201);
}

// GET /user/{id}
if ($method === 'GET' && preg_match('#^/user/([^/]+)$#', $path, $m)) {
    $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
    $stmt->execute([$m[1]]);
    $user = $stmt->fetch();
    if (!$user) {
        jsonError('User not found', 404);
    }
    jsonResponse($user);
}

// Fallback
jsonError('Endpoint not found', 404);
