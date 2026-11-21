CREATE TABLE trans_backup AS
SELECT *
FROM trans;

SELECT COUNT(*) AS backup_records
FROM trans_backup;