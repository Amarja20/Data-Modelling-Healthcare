-- Optimized query for retrieving high-priority appointments with a probability_dna greater than 0.9. An index on the priority and probability_dna columns is created to speed up the filtering process.

CREATE INDEX idx_unified_priority_probability ON Unified_Predictions(priority, probability_dna);

-- Use EXPLAIN ANALYZE to analyze the performance of the following 

EXPLAIN ANALYZE
SELECT 
    first_name, 
    last_name, 
    priority, 
    specialty, 
    hospital, 
    scheduled_fulldate AS scheduled_date, 
    probability_dna
FROM 
    Unified_Predictions
WHERE 
    priority = 'High' 
    AND probability_dna > 0.9;


-- Creating a materialized view to optimize the performance of querying average probability_dna
-- This view stores the average probability_dna grouped by clinic_name, 
-- allowing for faster access without recalculating the averages each time.
CREATE MATERIALIZED VIEW clinic_performance_avg AS
SELECT 
    clinic_name, 
    AVG(probability_dna) AS average_probability_dna
FROM 
    Unified_Predictions
GROUP BY 
    clinic_name;


-- Querying the materialized view to retrieve the top 3 clinics based on average probability_dna.
-- This query is more efficient as it accesses precomputed data.
SELECT * 
FROM clinic_performance_avg
ORDER BY average_probability_dna DESC
LIMIT 3;


-- Optimized query using window functions to calculate engagement rate percentage for each patient
-- This approach eliminates the need for GROUP BY, allowing for a more flexible and potentially efficient calculation.
SELECT 
    patient_id,
    first_name,
    last_name,
    ROUND(
        (SUM(CASE WHEN probability_dna > 0.8 THEN 1 ELSE 0 END) OVER (PARTITION BY patient_id)::decimal / 
         COUNT(*) OVER (PARTITION BY patient_id)) * 100, 2) AS engagement_rate_percentage
FROM 
    Unified_Predictions
ORDER BY 
    engagement_rate_percentage DESC;


-- Optimized query using  Create an index on patient_id and probability_dna to improve the performance of queries filtering on missed appointments.
CREATE INDEX idx_patient_id_probability_dna_missed 
ON Unified_Prediction (patient_id, probability_dna);


-- Use EXPLAIN ANALYZE to analyze the performance of the following 
-- query that counts missed appointments for patients with a 
-- probability_dna greater than 0.85. This will provide execution 
-- statistics and the query execution plan, helping to verify 
-- if the index is utilized effectively.
EXPLAIN ANALYZE
SELECT 
    patient_id,
    first_name,
    last_name,
    COUNT(*) AS missed_appointments_count
FROM 
    Unified_Prediction
WHERE 
    probability_dna > 0.85
GROUP BY 
    patient_id, first_name, last_name
HAVING 
    COUNT(*) > 3
ORDER BY 
    missed_appointments_count DESC;

