-- Сессии пользователей
CREATE TABLE user_session (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    token TEXT,
    last_activity INTEGER
);

-- Страны
CREATE TABLE countries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    image_url TEXT
);

-- Туры
CREATE TABLE tours (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT,
    price REAL,
    start_date INTEGER, 
    end_date INTEGER,
    hotel_id INTEGER,
    country_id INTEGER,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id),
    FOREIGN KEY (country_id) REFERENCES countries(id)
);

-- Отели
CREATE TABLE hotels (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT,
    location TEXT,
    star_rating INTEGER
);

-- Изображения отелей 
CREATE TABLE hotel_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hotel_id INTEGER,
    image_url TEXT,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

-- Удобства (например, бассейн, спа, Wi-Fi и т.д.)
CREATE TABLE amenities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    icon_url TEXT  -- Добавляем поле для URL иконки
);
-- Удобства отелей
CREATE TABLE hotel_amenities (
    hotel_id INTEGER,
    amenity_id INTEGER,
    PRIMARY KEY (hotel_id, amenity_id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(id),
    FOREIGN KEY (amenity_id) REFERENCES amenities(id)
);

-- Отзывы на отели
CREATE TABLE hotel_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hotel_id INTEGER,
    user_id INTEGER,
    rating INTEGER,
    comment TEXT,
    created_at INTEGER,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

-- Рейсы
CREATE TABLE flights (
    id INTEGER PRIMARY KEY,
    departure_airport TEXT,
    arrival_airport TEXT,
    departure_time INTEGER,
    arrival_time INTEGER,
    airline TEXT,
    flight_number TEXT,
    price REAL
);

-- Бронирования
CREATE TABLE bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    tour_id INTEGER,
    data TEXT
);

-- Рейсы в бронированиях
CREATE TABLE bookings_flights (
    booking_id INTEGER,
    flight_id INTEGER,
    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    FOREIGN KEY (flight_id) REFERENCES flights(id)
);