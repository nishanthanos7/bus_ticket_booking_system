-- 👤 USERS: Stores passenger details
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique ID that automatically increases for each new user
    name TEXT NOT NULL,                        -- Full name of the user (can't be empty)
    email TEXT NOT NULL UNIQUE,                -- User's email (must be unique)
    phone TEXT NOT NULL CHECK(length(phone) BETWEEN 8 AND 15), -- Phone number (between 8 and 15 digits)
    created_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the user was added
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP  -- Time when the user’s info was last updated
);

-- 🚌 BUSES: Information about buses available for booking
CREATE TABLE buses (
    bus_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique ID for each bus
    bus_number TEXT NOT NULL UNIQUE,          -- Bus number (must be unique)
    capacity INTEGER NOT NULL CHECK(capacity BETWEEN 20 AND 100), -- Number of seats (must be between 20 and 100)
    created_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the bus was added
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP  -- Time when bus details were last updated
);

-- 🗺️ ROUTES: Information about travel routes (from one place to another)
CREATE TABLE routes (
    route_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique ID for each route
    source TEXT NOT NULL,                      -- Starting location (e.g., Kathmandu)
    destination TEXT NOT NULL,                 -- Destination location (e.g., Pokhara)
    created_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the route was added
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the route was last updated
    UNIQUE(source, destination) -- No two identical routes (e.g., no two Kathmandu to Pokhara routes)
);

-- ⏰ SCHEDULES: When buses run and which routes they take
CREATE TABLE schedules (
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique ID for each bus trip
    bus_id INTEGER NOT NULL,            -- Which bus is used for the trip (links to buses table)
    route_id INTEGER NOT NULL,          -- Which route the bus is taking (links to routes table)
    departure_time TEXT NOT NULL,       -- Time when the bus will leave
    arrival_time TEXT NOT NULL,         -- Time when the bus will arrive
    created_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the schedule was created
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the schedule was last updated
    -- FOREIGN KEY (bus_id) links this schedule to an existing bus.
    FOREIGN KEY (bus_id) REFERENCES buses(bus_id) ON DELETE CASCADE, 
    -- If the bus is deleted, all schedules that use this bus will also be deleted automatically.
    
    -- FOREIGN KEY (route_id) links this schedule to an existing route.
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE
    -- If the route is deleted, all schedules that use this route will also be deleted automatically.
);

-- 💺 BOOKINGS: Records each time a passenger reserves a seat on a bus
CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique booking ID
    user_id INTEGER NOT NULL,           -- Who made the booking (links to users table)
    schedule_id INTEGER NOT NULL,       -- Which schedule was booked (links to schedules table)
    seat_number INTEGER NOT NULL CHECK(seat_number > 0), -- The seat number (must be positive)
    created_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the booking was made
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the booking was last updated
    -- FOREIGN KEY (user_id) links this booking to an existing user.
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE, 
    -- If the user is deleted, all their bookings will also be deleted automatically.
    
    -- FOREIGN KEY (schedule_id) links this booking to an existing schedule.
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE, 
    -- If the schedule is deleted, all bookings for that schedule will be deleted automatically.
    
    -- Ensures the same seat can't be booked twice on the same trip.
    UNIQUE(schedule_id, seat_number) 
);

-- 💳 PAYMENTS: Stores payment details for each booking
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique payment ID
    booking_id INTEGER NOT NULL UNIQUE, -- Links this payment to a specific booking
    amount REAL NOT NULL CHECK(amount >= 0), -- Payment amount (must be 0 or more)
    status TEXT NOT NULL CHECK(status IN ('PAID', 'PENDING', 'FAILED')), -- Payment status (e.g., 'PAID')
    created_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the payment was made
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP, -- Time when the payment was last updated
    -- FOREIGN KEY (booking_id) links this payment to an existing booking.
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE 
    -- If the booking is deleted, the payment linked to it will also be deleted automatically.
);