
-- Query 1: Select patients with high priority and probability_dna greater than 0.9
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

-- Query 2: Get the top 3 clinics with the highest average probability_dna
SELECT 
    clinic_name,
    round(AVG(probability_dna),2) AS average_probability_dna
FROM 
    Unified_Predictions
GROUP BY 
    clinic_name
ORDER BY 
    average_probability_dna DESC
LIMIT 3;

-- Query 3: Calculate engagement rate for each patient based on probability_dna
SELECT 
    patient_id,
    first_name,
    last_name,
    ROUND((SUM(CASE WHEN probability_dna > 0.8 THEN 1 ELSE 0 END)::decimal / COUNT(*)) * 100, 2) AS engagement_rate_percentage
FROM 
    Unified_Predictions
GROUP BY 
    patient_id, first_name, last_name
ORDER BY 
    engagement_rate_percentage DESC;

-- Query 4: Identify patients with more than three missed appointments (probability_dna > 0.85)
SELECT 
    patient_id,
    first_name,
    last_name,
    COUNT(*) AS missed_appointments_count
FROM 
    Unified_Predictions
WHERE 
    probability_dna > 0.85
GROUP BY 
    patient_id, first_name, last_name
HAVING 
    COUNT(*) > 3
ORDER BY 
    missed_appointments_count DESC;
