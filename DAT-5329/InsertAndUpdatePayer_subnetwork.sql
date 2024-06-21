BEGIN TRANSACTION;

BEGIN TRY
    -- Declare variables to hold data from the existing record
    DECLARE @UpdateNote VARCHAR(MAX), @UpdatedBy VARCHAR(255), @Updated DATETIME2,
            @ShowsInTypeahead BIT, @PPC VARCHAR(255), @Payer_SubNetwork_Description VARCHAR(MAX),
            @Payer_Key INT, @FeedAvailable BIT, @CreatedBy VARCHAR(255), @Created DATETIME2,
            @Application BIT;

    -- Retrieve data from the existing record with Key = 2801
    SELECT 
        @UpdateNote = UpdateNote, 
        @UpdatedBy = UpdatedBy, 
        @Updated = Updated,
        @ShowsInTypeahead = ShowsInTypeahead, 
        @PPC = PPC, 
        @Payer_SubNetwork_Description = Payer_SubNetwork_Description,
        @Payer_Key = Payer_Key,
        @FeedAvailable = FeedAvailable,
        @CreatedBy = CreatedBy,
        @Created = Created,
        @Application = Application
    FROM 
        Compass_CORE.dbo.Payer_Subnetwork
    WHERE 
        Payer_SubNetwork_Key = 2801;

    -- Insert a new record with Key = 3319 using captured values
    INSERT INTO Compass_CORE.dbo.Payer_Subnetwork 
        (Payer_SubNetwork_Key, UpdateNote, UpdatedBy, Updated, ShowsInTypeahead, PPC, 
         Payer_SubNetwork_Description, Payer_Key, FeedAvailable, CreatedBy, Created, Application)
    VALUES 
        (3319, @UpdateNote, @UpdatedBy, @Updated, @ShowsInTypeahead, @PPC, 
         @Payer_SubNetwork_Description, @Payer_Key, @FeedAvailable, @CreatedBy, @Created, @Application);

    -- Update referencing tables
    UPDATE Compass_CORE.templates.Template_Provider_INN
    SET Payer_SubNetwork_Key = 3319
    WHERE Payer_SubNetwork_Key = 2801;

    UPDATE Compass_CORE.templates.Template_Plan
    SET Payer_SubNetwork_Key = 3319
    WHERE Payer_SubNetwork_Key = 2801;

    COMMIT TRANSACTION;
    PRINT 'All updates and insertions successfully committed.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
END CATCH;


-- the above code did not work in PROD1 because data already existed there
-- the below solution was implemented after talking to jimmy




update  Compass_CORE.dbo.Payer_Subnetwork  set PPC = 5413
WHERE Payer_SubNetwork_Key in (3319)
and PPC is null ;

update  Compass_CORE.dbo.Payer_Subnetwork
set PPC = NUll
WHERE Payer_SubNetwork_Key = 2801
and PPC = 5413 ;



UPDATE Compass_CORE.dbo.Payer_Subnetwork 
SET 
    Updated = GETDATE(), -- Sets the Updated column to the current datetime
    UpdatedBy = 'A1104181', -- Sets the UpdatedBy column to the specified value
    UpdateNote = 'PPC was Null, updated to 5413' -- Sets the UpdateNote column to the specified text
WHERE 
    Payer_SubNetwork_Key = 3319 -- The specific key you want to update
    AND PPC = 5413; -- Ensures only rows with PPC = 5413 are updated
