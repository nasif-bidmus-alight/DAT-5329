WITH DistinctChat AS
(
    SELECT
        [Activity_ID],
        [Activity_SF_ID],
        [Activity_Type],
        [Assigned_To_SF_ID],
        [Related_To_ID],
        [Related_To_Type],
        pt.[Person_SF_ID],
        [Participant_Name],
        [Company_Code],
        [Client_Name],
        [Task_Subject],
        pt.[Call_Type],
        [Created_Date],
        CASE
            WHEN vp.Relationship = 'Spouse/Partner' THEN CONCAT(vp.[Employee ID], 'S')
            ELSE vp.[Employee ID]
        END AS [Employee ID],
        [User_Name],
        [Interaction_Owner_Role],
        [Role_Flag],
        ROW_NUMBER() OVER (PARTITION BY vp.[Employee ID] ORDER BY pt.[Created_Date]) AS RowNum
    FROM [mart].[vw_Participant_Interactions] pt
    JOIN [mart].[vw_Person] vp ON vp.Person_SF_ID = pt.Person_SF_ID
    WHERE [Company_Code] = 'MASTERCARD'
    AND Activity_Type NOT IN ('Direct Message')
    AND Task_Subject LIKE '%chat%'
    AND [Created_Date] >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
    AND [Employee ID] IS NOT NULL
),
DistinctdirectMessage AS
(
    SELECT
        [Activity_ID],
        [Activity_SF_ID],
        [Activity_Type],
        [Assigned_To_SF_ID],
        [Related_To_ID],
        [Related_To_Type],
        pt.[Person_SF_ID],
        [Participant_Name],
        [Company_Code],
        [Client_Name],
        [Task_Subject],
        [Call_Type],
        [Created_Date],
        CASE
            WHEN vp.Relationship = 'Spouse/Partner' THEN CONCAT(vp.[Employee ID], 'S')
            ELSE vp.[Employee ID]
        END AS [Employee ID],
        ROW_NUMBER() OVER (PARTITION BY vp.[Employee ID] ORDER BY pt.[Created_Date]) AS RowNum
    FROM [mart].[vw_Participant_Interactions] pt
    JOIN [mart].[vw_Person] vp ON vp.Person_SF_ID = pt.Person_SF_ID
    WHERE [Company_Code] = 'MASTERCARD'
    AND Activity_Type = 'Direct Message'
    AND [Created_Date] >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
    AND [Employee ID] IS NOT NULL
),
DistinctCalltask AS
(
    SELECT
        [Activity_ID],
        [Activity_SF_ID],
        [Activity_Type],
        [Assigned_To_SF_ID],
        [Related_To_ID],
        [Related_To_Type],
        pt.[Person_SF_ID],
        [Participant_Name],
        [Company_Code],
        [Client_Name],
        [Task_Subject],
        pt.[Call_Type],
        t.[Completed_Date],
        CASE
            WHEN vp.Relationship = 'Spouse/Partner' THEN CONCAT(vp.[Employee ID], 'S')
            ELSE vp.[Employee ID]
        END AS [Employee ID],
        ROW_NUMBER() OVER (PARTITION BY vp.[Employee ID] ORDER BY t.[Completed_Date]) AS RowNum
    FROM [mart].[vw_Participant_Interactions] pt
    JOIN [mart].[vw_Person] vp ON vp.Person_SF_ID = pt.Person_SF_ID
    JOIN [dbo].[task] t ON t.Task_ID = pt.Activity_ID
    WHERE [Company_Code] = 'MASTERCARD'
    AND Activity_Type NOT IN ('Direct Message')
    AND t.Completed_Date >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
    AND t.Completed_Date IS NOT NULL
    AND [Employee ID] IS NOT NULL
    AND pt.Call_Type = 'Inbound'
),
Distinctwebinars AS
(
    SELECT
        [data_source],
        [Intake Date],
        [Event Date],
        CASE
            WHEN [Caller Relationship] = 'Spouse/Partner' THEN CONCAT([Employee ID], 'S')
            ELSE [Employee ID]
        END AS [Employee ID],
        ROW_NUMBER() OVER (PARTITION BY [Employee ID] ORDER BY [Intake Date]) AS RowNum,
        [data_type],
        [Client ID],
        [Company],
        [Company Code],
        [Service Request Type]
    FROM [mart].[vw_Combined2_Webinars]
    WHERE [Company Code] = 'mastercard'
    AND [Intake is Engaged] = 'Engaged'
    AND [Event Date] >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
    AND [Intake Date] IS NOT NULL
    AND data_type = 'Service Request'
    AND [Employee ID] IS NOT NULL
    AND [Client ID] NOT LIKE '00Q%'
)
-- Combine the results from all four CTEs
SELECT
    ROW_NUMBER() OVER (ORDER BY [Employee ID]) AS SequenceNumber,
    '5067' AS SponsorID,
    [Employee ID] AS EmployeeID,
    'CONMEDCY' AS EventCode,
    CONVERT(VARCHAR(8), [Created_Date], 112) AS EventDate
FROM DistinctChat
WHERE RowNum = 1
UNION ALL
SELECT
    ROW_NUMBER() OVER (ORDER BY [Employee ID]) AS SequenceNumber,
    '5067' AS SponsorID,
    [Employee ID] AS EmployeeID,
    'CONMEDCY' AS EventCode,
    CONVERT(VARCHAR(8), [Created_Date], 112) AS EventDate
FROM DistinctdirectMessage
WHERE RowNum = 1
UNION ALL
SELECT
    ROW_NUMBER() OVER (ORDER BY [Employee ID]) AS SequenceNumber,
    '5067' AS SponsorID,
    [Employee ID] AS EmployeeID,
    'CONMEDCY' AS EventCode,
    CONVERT(VARCHAR(8), [Completed_Date], 112) AS EventDate
FROM DistinctCalltask
WHERE RowNum = 1
UNION ALL
SELECT
    ROW_NUMBER() OVER (ORDER BY [Employee ID]) AS SequenceNumber,
    '5067' AS SponsorID,
    [Employee ID] AS EmployeeID,
    'CONMEDCY' AS EventCode,
    CONVERT(VARCHAR(8), [Intake Date], 112) AS EventDate
FROM Distinctwebinars
WHERE RowNum = 1;