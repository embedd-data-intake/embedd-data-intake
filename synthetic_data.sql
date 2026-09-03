-- Common Table Expressions to define reusable data sets
WITH
-- 1. Generated Users
inserted_users AS (
    INSERT INTO users (id, password_hash, created_at)
    VALUES
        ('11111111-1111-4111-8111-111111111111', '$2a$12$eImiTXuWVxfM37uY4JANjOL.88T8/1M3C9/z/KxX.S5YgX71sP2uS', NOW() - INTERVAL '30 days'),
        ('22222222-2222-4222-8222-222222222222', '$2a$12$eImiTXuWVxfM37uY4JANjOL.88T8/1M3C9/z/KxX.S5YgX71sP2uS', NOW() - INTERVAL '15 days'),
        ('33333333-3333-4333-8333-333333333333', '$2a$12$eImiTXuWVxfM37uY4JANjOL.88T8/1M3C9/z/KxX.S5YgX71sP2uS', NOW() - INTERVAL '5 days')
    RETURNING id
),

-- 2. Generated Emails
inserted_emails AS (
    INSERT INTO emails (id, email_address, created_at)
    VALUES
        ('e1111111-1111-4111-8111-111111111111', 'alex.dev@example.com', NOW() - INTERVAL '30 days'),
        ('e2222222-2222-4222-8222-222222222222', 'sam.tech@example.com', NOW() - INTERVAL '15 days'),
        ('e3333333-3333-4333-8333-333333333333', 'jordan.ops@example.com', NOW() - INTERVAL '5 days')
    RETURNING id
),

-- 3. Generated Devices
inserted_devices AS (
    INSERT INTO devices (id, device_name, created_at)
    VALUES
        ('d1111111-1111-4111-8111-111111111111', 'Edge Gateway Alpha', NOW() - INTERVAL '30 days'),
        ('d2222222-2222-4222-8222-222222222222', 'Environment Sensor Node', NOW() - INTERVAL '15 days'),
        ('d3333333-3333-4333-8333-333333333333', 'Telemetry Gateway Beta', NOW() - INTERVAL '5 days')
    RETURNING id
),

-- 4. Generated Attributes
inserted_attributes AS (
    INSERT INTO foreign_schema.attributes (id, name, type)
    VALUES
        ('a1111111-1111-4111-8111-111111111111', 'temperature', 'NUMBER'),
        ('a2222222-2222-4222-8222-222222222222', 'humidity', 'NUMBER'),
        ('a3333333-3333-4333-8333-333333333333', 'firmware_version', 'STRING'),
        ('a4444444-4444-4444-8444-444444444444', 'is_active', 'BOOLEAN')
    RETURNING id
)

-- 5. User-Email Mappings
INSERT INTO user_email (user_id, email_id, created_at)
VALUES
    ('11111111-1111-4111-8111-111111111111', 'e1111111-1111-4111-8111-111111111111', NOW() - INTERVAL '30 days'),
    ('22222222-2222-4222-8222-222222222222', 'e2222222-2222-4222-8222-222222222222', NOW() - INTERVAL '15 days'),
    ('33333333-3333-4333-8333-333333333333', 'e3333333-3333-4333-8333-333333333333', NOW() - INTERVAL '5 days');

-- 6. User-Device Mappings
INSERT INTO user_device (user_id, device_id, role, created_at)
VALUES
    ('11111111-1111-4111-8111-111111111111', 'd1111111-1111-4111-8111-111111111111', 'OWNER', NOW() - INTERVAL '30 days'),
    ('11111111-1111-4111-8111-111111111111', 'd2222222-2222-4222-8222-222222222222', 'ADMIN', NOW() - INTERVAL '15 days'),
    ('22222222-2222-4222-8222-222222222222', 'd2222222-2222-4222-8222-222222222222', 'OWNER', NOW() - INTERVAL '15 days'),
    ('33333333-3333-4333-8333-333333333333', 'd3333333-3333-4333-8333-333333333333', 'OWNER', NOW() - INTERVAL '5 days');

-- 7. Active Refresh Tokens
INSERT INTO refresh_tokens (user_id, token, expires_at, created_at)
VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1111111-1111-4111-8111-111111111111', NOW() + INTERVAL '7 days', NOW()),
    ('22222222-2222-4222-8222-222222222222', 'f2222222-2222-4222-8222-222222222222', NOW() + INTERVAL '7 days', NOW()),
    ('33333333-3333-4333-8333-333333333333', 'f3333333-3333-4333-8333-333333333333', NOW() - INTERVAL '1 day', NOW() - INTERVAL '8 days');

-- 8. TimescaleDB Sensor Data Generation (100 series records over 24 hours)
INSERT INTO foreign_schema.sensor_data (timestamp, device_id, attribute_id, val_num, val_string, val_boolean)
SELECT 
    gs.ts AS timestamp,
    d.id AS device_id,
    a.id AS attribute_id,
    CASE 
        WHEN a.type = 'NUMBER' AND a.name = 'temperature' THEN ROUND((20.0 + (random() * 8.0))::numeric, 2)
        WHEN a.type = 'NUMBER' AND a.name = 'humidity' THEN ROUND((40.0 + (random() * 35.0))::numeric, 2)
        ELSE NULL 
    END AS val_num,
    CASE 
        WHEN a.type = 'STRING' THEN 'v2.4.1' 
        ELSE NULL 
    END AS val_string,
    CASE 
        WHEN a.type = 'BOOLEAN' THEN TRUE 
        ELSE NULL 
    END AS val_boolean
FROM generate_series(
    NOW() - INTERVAL '24 hours', 
    NOW(), 
    INTERVAL '15 minutes'
) AS gs(ts)
CROSS JOIN devices d
CROSS JOIN foreign_schema.attributes a;