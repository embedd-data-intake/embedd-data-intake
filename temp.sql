CREATE TABLE IF NOT EXISTS attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(64) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS sensor_data (
    timestamp TIMESTAMPTZ NOT NULL,
    device_id UUID NOT NULL,
    attribute_id UUID NOT NULL REFERENCES attributes(id),
    val_num DOUBLE PRECISION,
    val_string VARCHAR(255),
    val_boolean BOOLEAN,
    PRIMARY KEY (timestamp, device_id, attribute_id)
);

SELECT create_hypertable(
       'sensor_data',
       'timestamp',
       if_not_exists => TRUE
);
CREATE INDEX IF NOT EXISTS idx_device_time ON sensor_data (device_id, timestamp DESC);
