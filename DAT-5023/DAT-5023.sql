select    vcse.Client_Name
,vp.[First Name] as [Patient_FIRST_Name]
,vp.[Last Name] as [Patient_LAST_Name]
,case
	 when vp.Relationship like '%Spouse%'     then LEFT(Participant_Name, CHARINDEX(' ', Participant_Name) - 1) 
	 else vp.[First Name]
end as [EE_FIRST_Name]
,case
	 when vp.Relationship = 'Spouse/Partner'  Then RIGHT(Participant_Name, LEN(Participant_Name) - CHARINDEX(' ', Participant_Name))
	 else vp.[Last Name]
end as [EE_LAST_Name]
,case
when vp.Relationship = 'Employee' THEN 'Self'
when vp.Relationship = 'Spouse/Partner' then 'Spouse'
else vp.relationship
end as [Relationship]
,vcse.Insurance_Carrier
,Insurance_ID
--,vcse.Participant_Employee_ID
,vp.[Employee ID]
,vp.[Employee SSN]
,FORMAT(vcse.[Participant_DOB], 'MM/dd/yyyy') AS [Patient_Birthdate]
,vcse.Participant_Gender as Patient_Gender
,case
	when vcse.SDS_Conditon = 'HYSTERECTOMY' then upper('UTERINE')
	else upper(vcse.SDS_Conditon)
end as SDS_Type
,vcse.Joints_Affected
,FORMAT(vcse.Open_Date, 'yyyyMMdd') AS [Date_Opened]
,vcse.Status as Current_Status
,vcse.Penalty_Waived
,vcse.Enrollment_Required
,vcse.Survey_Status
,format(vcse.Survey_Completion_Date, 'yyyyMMdd') as Survey_Completed_Date, vcse.Product_Type
,vcse.Service_Request_ID
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
    AND vp.[Company Code] = 'Alstom'
    AND (vcse.Data_Type = 'Service Request')
    AND vcse.Intake_is_Engaged = 'Engaged'
	and vcse.Product_Type = 'SDS'
	and sr.Intake_Date >= '2019-01-01';