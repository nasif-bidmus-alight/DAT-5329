SELECT
    
	vp.[work site] AS Branch_Code,
    vp.[Custom Field 2] AS Program_Type,
	vp.[First Name] AS Member_First_Name,
	vp.[Last Name] AS Member_Last_Name,
    CASE
        WHEN vp.Gender = 'Female' THEN 'F'
        WHEN vp.Gender = 'Male' THEN 'M'
        ELSE vp.Gender
    END AS Member_Gender,
    CASE
        WHEN vp.Relationship = 'Employee' THEN 'EE'
        WHEN vp.Relationship = 'Spouse/Partner' THEN 'SP'
        WHEN vp.Relationship = 'Dependent' THEN 'D'
        ELSE vp.Relationship
    END AS Member_Relationship,
    CONVERT(varchar, vp.[Birth Date],101) AS Member_Birth_Date,
	CONVERT(varchar, Survey_Completion_Date,101) AS Survey_Completion_Date,
    vp.[Employee SSN]
FROM [mart].[vw_Combined2_Summary_Einstein] vcse
JOIN dbo.service_request sr ON sr.Service_Request_SF_ID = vcse.Service_Request_ID
 JOIN [mart].[vw_Person] vp ON vp.Person_SF_ID = vcse.Contact_Record_ID
WHERE Survey_Completion_Date IS NOT NULL
    AND Product_Type = 'SDS'
    AND Client_Code = 'sbd'
    AND Eligibile_For_Incentive = 'Yes'
    AND Data_Type = 'Case'
    AND Intake_is_Engaged = 'Engaged'
	and Participant_Is_Patient = 1
    AND Survey_Completion_Date >= DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0)
    AND Survey_Completion_Date < DATEADD(day, 1, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
	or (vp.[Employee SSN] = '404216968' AND Product_Type = 'SDS'
    AND Client_Code = 'sbd'
    AND Eligibile_For_Incentive = 'Yes'
    AND Data_Type = 'Case'
    AND Intake_is_Engaged = 'Engaged')
ORDER BY Survey_Completion_Date DESC;