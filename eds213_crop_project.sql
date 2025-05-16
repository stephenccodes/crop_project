-- Pull data into tables
CREATE TABLE crop_calendar AS
    SELECT * FROM read_csv('data_processed/crop_calendar_clean.csv');

CREATE TABLE crop_yield AS
    SELECT * FROM read_csv('data_processed/fao_clean.csv');

-- Make an intermediary table

CREATE TABLE yield_calendar AS
SELECT * 
FROM crop_yield
LEFT JOIN crop_calendar
ON crop_yield.country = crop_calendar.country;



