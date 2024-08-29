use Compass_REPORTING

UPDATE dbo.rpt_ConsultingQAAudits
SET CreatedDate = '2024-07-31 00:00:00.000',
    CalendarYearMonth = '2024-07'
WHERE CaseNumber = 45281;
-- Verify the update by selecting the top 10 records
SELECT TOP 10 CaseNumber,CreatedDate,Quarter,CalendarYearMonth
FROM dbo.rpt_ConsultingQAAudits
WHERE CaseNumber = 45281;