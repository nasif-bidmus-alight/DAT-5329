SELECT
    vp.[First Name] AS [Member's First Name],
    '' AS [Member's Middle Name],
    vp.[Last Name] AS [Member's Last Name],
    FORMAT(vp.[Birth Date], 'yyyy.MM.dd') AS [Member's Date of Birth],
    '' AS [Member's Effective Date of Coverage],
    '' AS [Member's Term Date of Coverage],
    CASE
        WHEN vp.Gender = 'Female' THEN 'F'
        WHEN vp.Gender = 'Male' THEN 'M'
        ELSE vp.Gender
    END AS Member_Gender,
    vp.[Insurance ID] AS [Subscriber's Unique Identifier],
    '' AS [WGS Group Number and Sub Group],
    CASE
        WHEN vcse.SDS_Conditon = 'Back' THEN 'WCMBK'
        WHEN vcse.SDS_Conditon = 'Hip' THEN 'WCM' + LEFT(vcse.Joints_Affected, 1) + 'HIP'
        WHEN vcse.SDS_Conditon = 'Knee' THEN 'WCM' + LEFT(vcse.Joints_Affected, 1) + 'KNE'
        ELSE 'WCM' + vcse.SDS_Conditon
    END AS Type_Of_BD_Program_Code_Completed,
    FORMAT(sr.SDS_Req_Date, 'yyyy.MM.dd') AS [Program_Benefit Qualifier_Date],
    FORMAT(DATEADD(YEAR, 2, sr.SDS_Req_Date), 'yyyy.MM.dd') AS [Program_Benefit Expiry_Date]
FROM
    [mart].[vw_Combined2_Summary_Einstein] vcse
JOIN
    dbo.service_request sr ON sr.Service_Request_SF_ID = vcse.Service_Request_ID
JOIN
    [mart].[vw_Person] vp ON vp.Person_SF_ID = vcse.Contact_Record_ID
RIGHT JOIN
    [mart].[vw_ServiceRequest_with_ProgramType] spt ON spt.Service_Request_SF_ID = vcse.Service_Request_ID
WHERE
    Survey_Completion_Date IS NOT NULL
    AND spt.Program_Type = 'SDS'
    AND [Company Code] = 'WELLS'
    AND spt.Employer_ID = '4794' -- 'Wells Fargo'
    AND Data_Type = 'Case'
    AND Intake_is_Engaged = 'Engaged'
    AND YEAR(spt.[Intake_Date]) = CAST(YEAR(GETDATE()) AS VARCHAR)
    AND spt.Open_Date BETWEEN '2020-01-01' AND GETDATE()
    AND spt.Closed_Reason != 'Duplicate'
    AND vcse.Product_Type = 'SDS';