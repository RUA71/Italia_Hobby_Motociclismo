-- Italia Hobby Motociclismo — Database Schema
-- MySQL / MariaDB — Aruba.it

CREATE DATABASE IF NOT EXISTS ihm_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ihm_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id              VARCHAR(64)  PRIMARY KEY,
    nickname        VARCHAR(50)  NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL DEFAULT '',
    surname         VARCHAR(100) NOT NULL DEFAULT '',
    city            VARCHAR(100) NOT NULL,
    country         VARCHAR(100) NOT NULL,
    motorbike_brand VARCHAR(100) NOT NULL,
    motorbike_model VARCHAR(100) NOT NULL,
    motorbike_type  VARCHAR(100) NOT NULL DEFAULT '',
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Events table
CREATE TABLE IF NOT EXISTS events (
    id          VARCHAR(64)   PRIMARY KEY,
    title       VARCHAR(200)  NOT NULL,
    description TEXT          NOT NULL DEFAULT '',
    date        DATETIME      NOT NULL,
    latitude    DOUBLE        NOT NULL,
    longitude   DOUBLE        NOT NULL,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Subscriptions table (many-to-many: users <-> events)
CREATE TABLE IF NOT EXISTS subscriptions (
    user_id   VARCHAR(64) NOT NULL,
    event_id  VARCHAR(64) NOT NULL,
    joined_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, event_id),
    FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id        VARCHAR(64)  PRIMARY KEY,
    event_id  VARCHAR(64)  NOT NULL,
    sender_id VARCHAR(64)  NOT NULL,
    text      TEXT         NOT NULL,
    timestamp DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id)  REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id)  ON DELETE CASCADE,
    INDEX idx_event_timestamp (event_id, timestamp)
) ENGINE=InnoDB;
