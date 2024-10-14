
-- Query 1: Select patients with high priority and probability_dna greater than 0.9
SELECT
    p.first_name,
    p.last_name,
    a.priority,
    a.specialty,
    a.hospital,
    d.fulldate AS scheduled_date,
    pr.probability_dna
FROM
    FACT_APPOINTMENT fa
JOIN
    DIM_PATIENT p ON fa.patient_id = p.patient_id
JOIN
    DIM_APPOINTMENT a ON fa.appointment_id = a.appointment_id
JOIN
    FACT_PREDICTION fp ON fa.factap_pk = fp.factap_pk
JOIN
    DIM_PREDICTION pr ON fp.prediction_id = pr.prediction_id
JOIN
    DIM_DATE d ON fa.scheduled_date_id = d.date_id
WHERE
    a.priority = 'High'
    AND pr.probability_dna > 0.9;

-- Query 2: Get the top 3 clinics with the highest average probability_dna
SELECT
    c.clinic_name,
    round(AVG(pr.probability_dna),2) AS avg_probability_dna
FROM
    FACT_APPOINTMENT fa
JOIN
    DIM_CLINIC c ON fa.clinic_id = c.clinic_id
JOIN
    FACT_PREDICTION fp ON fa.factap_pk = fp.factap_pk
JOIN
    DIM_PREDICTION pr ON fp.prediction_id = pr.prediction_id
GROUP BY
    c.clinic_name
ORDER BY
    avg_probability_dna DESC
LIMIT 3;

-- Query 3: Calculate engagement rate for each patient based on probability_dna
SELECT
    p.first_name,
    p.last_name,
    round((COUNT(CASE WHEN pr.probability_dna > 0.8 THEN 1 END) * 100.0 / COUNT(*)),2) AS engagement_rate
FROM
    FACT_APPOINTMENT fa
JOIN
    DIM_PATIENT p ON fa.patient_id = p.patient_id
JOIN
    FACT_PREDICTION fp ON fa.factap_pk = fp.factap_pk
JOIN
    DIM_PREDICTION pr ON fp.prediction_id = pr.prediction_id
GROUP BY
    p.first_name, p.last_name
ORDER BY
    engagement_rate DESC;

-- Query 4: Identify patients with more than three missed appointments (probability_dna > 0.85)
SELECT
    p.first_name,
    p.last_name,
    COUNT(*) AS missed_appointments
FROM
    FACT_APPOINTMENT fa
JOIN
    DIM_PATIENT p ON fa.patient_id = p.patient_id
JOIN
    FACT_PREDICTION fp ON fa.factap_pk = fp.factap_pk
JOIN
    DIM_PREDICTION pr ON fp.prediction_id = pr.prediction_id
WHERE
    pr.probability_dna > 0.85
GROUP BY
    p.first_name, p.last_name
HAVING
    COUNT(*) > 3;
