-- Create the table schema for weather conditions
CREATE TABLE crop_calendar (
    country VARCHAR,
    crop VARCHAR,
    plant_median DOUBLE,
    temp_average DOUBLE,
    temp_at_planting DOUBLE,
    precip_at_planting DOUBLE,
    crop_code INTEGER PRIMARY KEY
    );

---- UNIQUE(country, crop) 

-- Pull data into table
COPY crop_calendar FROM 'data_processed/crop_calendar_clean.csv' (header TRUE);    

-- Create the table schema for crop yields
CREATE TABLE crop_yield (
    id INTEGER PRIMARY KEY, 
    country VARCHAR,
    quant DOUBLE,
    unit VARCHAR,
    crop VARCHAR,
    time DOUBLE,
    item_code DOUBLE,
    FOREIGN KEY (item_code) REFERENCES crop_calendar(crop_code)
);

-- Pull data into table
COPY crop_yield FROM 'data_processed/fao_clean.csv' (header TRUE);    

-- Merge tables
CREATE TABLE yield_calendar AS
SELECT * 
FROM crop_yield
LEFT JOIN crop_calendar
ON crop_yield.country = crop_calendar.country
ON crop_yield.crop = crop_yield.crop;


-- Create the table schema for intermediate table
CREATE TABLE lookup_crop_country (
    id INTEGER PRIMARY KEY,
    item_code INTEGER,
    country VARCHAR,
    crop VARCHAR,
    time DOUBLE,
    crop_code INTEGER,
    FOREIGN KEY (item_code) REFERENCES fao_clean(item_code),     
    FOREIGN KEY (crop_code) REFERENCES crop_calendar(crop_code)
);

INSERT INTO lookup_crop_country (id, item_code, country, crop, time, crop_code)
SELECT
    row_number() OVER (),         -- auto-incrementing lookup_id
    f.country,
    f.crop,
    f.time,
    f.item_code,
    c.crop_code
FROM fao_clean f
JOIN crop_calendar c
  ON f.country = c.country AND f.crop = c.crop
GROUP BY f.country, f.crop, f.time, f.item_code, c.crop_code;
