/*
 Optional least-privilege role.
 Run only after 001_schema.sql has completed successfully, as a database administrator.
 Do not grant db_owner and do not use sa for the application.
*/
SET NOCOUNT ON;

/*
 Validate the schema before changing permissions.
 Keep this validation and the grants in one batch so RETURN stops the script
 when the schema deployment has not completed.
*/
IF SCHEMA_ID(N'MSIGN') IS NULL
BEGIN
    RAISERROR(N'MSIGN security deployment stopped: schema MSIGN does not exist. Run docs/sql/001_schema.sql successfully first.', 16, 1);
    RETURN;
END;

IF OBJECT_ID(N'MSIGN.Users', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.Certificates', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.UserCertificates', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.Documents', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.SigningOperations', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.Signatures', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.SignatureVerifications', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.NetrikaTasks', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.NetrikaTaskDocuments', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.AuditLog', N'U') IS NULL
 OR OBJECT_ID(N'MSIGN.IntegrationSettings', N'U') IS NULL
BEGIN
    RAISERROR(N'MSIGN security deployment stopped: one or more required MSIGN tables are missing. Complete 001_schema.sql successfully first.', 16, 1);
    RETURN;
END;

IF DATABASE_PRINCIPAL_ID(N'MSIGN_AppRole') IS NULL
    CREATE ROLE MSIGN_AppRole AUTHORIZATION dbo;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::MSIGN TO MSIGN_AppRole;
GRANT DELETE ON OBJECT::MSIGN.UserCertificates TO MSIGN_AppRole;
GRANT DELETE ON OBJECT::MSIGN.IntegrationSettings TO MSIGN_AppRole;
DENY UPDATE, DELETE ON OBJECT::MSIGN.AuditLog TO MSIGN_AppRole;

PRINT N'MSIGN security permissions configured successfully. Assign a dedicated database user to MSIGN_AppRole.';
