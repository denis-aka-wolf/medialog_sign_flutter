/*
 Optional least-privilege role. Run after 001_schema.sql as a database administrator.
 Do not grant db_owner and do not use sa for the application.
*/
SET NOCOUNT ON;
GO
IF DATABASE_PRINCIPAL_ID(N'MSIGN_AppRole') IS NULL
 CREATE ROLE MSIGN_AppRole AUTHORIZATION dbo;
GO
GRANT SELECT,INSERT,UPDATE ON SCHEMA::MSIGN TO MSIGN_AppRole;
GRANT DELETE ON OBJECT::MSIGN.UserCertificates TO MSIGN_AppRole;
GRANT DELETE ON OBJECT::MSIGN.IntegrationSettings TO MSIGN_AppRole;
DENY UPDATE,DELETE ON OBJECT::MSIGN.AuditLog TO MSIGN_AppRole;
GO
/*
 After creating a dedicated database user, assign it:
 ALTER ROLE MSIGN_AppRole ADD MEMBER [MedialogSignAppUser];
 Replace the placeholder with the actual database principal.
*/
PRINT N'MSIGN_AppRole created. Assign a dedicated database user explicitly.';
GO
