/*
 Medialog Sign SQL Server schema. Target SQL Server 2016+.
 Creates application-owned objects in MSIGN. Does not modify native Medialog tables.
 Existing objects are not altered. Use versioned migrations for later changes.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF SCHEMA_ID(N'MSIGN') IS NULL EXEC(N'CREATE SCHEMA MSIGN AUTHORIZATION dbo;');
GO
IF OBJECT_ID(N'MSIGN.Users',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.Users(
  UserId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_Users PRIMARY KEY,
  MedialogUserId NVARCHAR(128) NULL, Login NVARCHAR(128) NOT NULL,
  FullName NVARCHAR(256) NOT NULL, Department NVARCHAR(256) NULL,
  JobTitle NVARCHAR(256) NULL, WindowsSid NVARCHAR(184) NULL,
  IsActive BIT NOT NULL CONSTRAINT DF_MSIGN_Users_Active DEFAULT(1),
  CanSignArbitrary BIT NOT NULL CONSTRAINT DF_MSIGN_Users_CanSign DEFAULT(0),
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Users_Created DEFAULT(SYSUTCDATETIME()),
  UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Users_Updated DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT UQ_MSIGN_Users_Login UNIQUE(Login)
 );
 CREATE UNIQUE INDEX UX_MSIGN_Users_MedialogId ON MSIGN.Users(MedialogUserId) WHERE MedialogUserId IS NOT NULL;
END;
GO
IF OBJECT_ID(N'MSIGN.Certificates',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.Certificates(
  CertificateId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_Certificates PRIMARY KEY,
  ThumbprintSha1 CHAR(40) NOT NULL, SerialNumber NVARCHAR(128) NULL,
  SubjectName NVARCHAR(1024) NOT NULL, IssuerName NVARCHAR(1024) NULL,
  ValidFrom DATETIME2(0) NULL, ValidTo DATETIME2(0) NULL,
  StoreName NVARCHAR(64) NULL, StoreLocation NVARCHAR(32) NULL,
  WindowsSid NVARCHAR(184) NULL, HasPrivateKey BIT NOT NULL CONSTRAINT DF_MSIGN_Certs_Key DEFAULT(0),
  IsDateRangeValid BIT NOT NULL CONSTRAINT DF_MSIGN_Certs_Date DEFAULT(0),
  LastSeenAt DATETIME2(3) NULL, LastSeenMachine NVARCHAR(256) NULL,
  CertificateDer VARBINARY(MAX) NULL, IsRevoked BIT NULL, RevocationCheckedAt DATETIME2(3) NULL,
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Certs_Created DEFAULT(SYSUTCDATETIME()),
  UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Certs_Updated DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT UQ_MSIGN_Certificates_Thumbprint UNIQUE(ThumbprintSha1)
 );
 CREATE INDEX IX_MSIGN_Certificates_ValidTo ON MSIGN.Certificates(ValidTo);
END;
GO
IF OBJECT_ID(N'MSIGN.UserCertificates',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.UserCertificates(
  UserCertificateId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_UserCertificates PRIMARY KEY,
  UserId BIGINT NOT NULL, CertificateId BIGINT NOT NULL,
  AssignmentStatus NVARCHAR(24) NOT NULL CONSTRAINT DF_MSIGN_UserCert_Status DEFAULT(N'active'),
  IsPrimary BIT NOT NULL CONSTRAINT DF_MSIGN_UserCert_Primary DEFAULT(0),
  AssignedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_UserCert_Assigned DEFAULT(SYSUTCDATETIME()),
  AssignedByUserId BIGINT NULL, RevokedAt DATETIME2(3) NULL, Notes NVARCHAR(1000) NULL,
  CONSTRAINT FK_MSIGN_UserCert_User FOREIGN KEY(UserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT FK_MSIGN_UserCert_Cert FOREIGN KEY(CertificateId) REFERENCES MSIGN.Certificates(CertificateId),
  CONSTRAINT FK_MSIGN_UserCert_AssignedBy FOREIGN KEY(AssignedByUserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT CK_MSIGN_UserCert_Status CHECK(AssignmentStatus IN(N'active',N'pending',N'revoked',N'expired'))
 );
 CREATE UNIQUE INDEX UX_MSIGN_UserCert_Active ON MSIGN.UserCertificates(UserId,CertificateId) WHERE RevokedAt IS NULL;
 CREATE INDEX IX_MSIGN_UserCert_Cert ON MSIGN.UserCertificates(CertificateId);
END;
GO
IF OBJECT_ID(N'MSIGN.Documents',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.Documents(
  DocumentId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_Documents PRIMARY KEY,
  PublicId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MSIGN_Documents_Public DEFAULT(NEWSEQUENTIALID()),
  DocumentNumber NVARCHAR(128) NULL, FileName NVARCHAR(512) NOT NULL,
  MimeType NVARCHAR(256) NULL, FileExtension NVARCHAR(32) NULL, FileSizeBytes BIGINT NULL,
  ContentSha256 BINARY(32) NULL, StorageUri NVARCHAR(2048) NULL, StorageProvider NVARCHAR(32) NULL,
  DocumentType NVARCHAR(64) NULL, SourceSystem NVARCHAR(64) NOT NULL CONSTRAINT DF_MSIGN_Documents_Source DEFAULT(N'local'),
  MedialogEntityId NVARCHAR(128) NULL, PatientId NVARCHAR(128) NULL, PatientDisplayName NVARCHAR(256) NULL,
  CreatedByUserId BIGINT NOT NULL,
  DocumentStatus NVARCHAR(32) NOT NULL CONSTRAINT DF_MSIGN_Documents_Status DEFAULT(N'draft'),
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Documents_Created DEFAULT(SYSUTCDATETIME()),
  UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Documents_Updated DEFAULT(SYSUTCDATETIME()),
  ArchivedAt DATETIME2(3) NULL,
  CONSTRAINT UQ_MSIGN_Documents_Public UNIQUE(PublicId),
  CONSTRAINT FK_MSIGN_Documents_User FOREIGN KEY(CreatedByUserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT CK_MSIGN_Documents_Size CHECK(FileSizeBytes IS NULL OR FileSizeBytes>=0),
  CONSTRAINT CK_MSIGN_Documents_Status CHECK(DocumentStatus IN(N'draft',N'ready',N'signing',N'signed',N'sent',N'completed',N'rejected',N'error',N'archived'))
 );
 CREATE INDEX IX_MSIGN_Documents_Created ON MSIGN.Documents(CreatedAt DESC);
 CREATE INDEX IX_MSIGN_Documents_Patient ON MSIGN.Documents(PatientId) WHERE PatientId IS NOT NULL;
 CREATE INDEX IX_MSIGN_Documents_Hash ON MSIGN.Documents(ContentSha256) WHERE ContentSha256 IS NOT NULL;
END;
GO
IF OBJECT_ID(N'MSIGN.SigningOperations',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.SigningOperations(
  SigningOperationId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_SigningOperations PRIMARY KEY,
  OperationPublicId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MSIGN_Signing_Public DEFAULT(NEWSEQUENTIALID()),
  DocumentId BIGINT NOT NULL, UserId BIGINT NOT NULL, CertificateId BIGINT NULL,
  OperationType NVARCHAR(32) NOT NULL CONSTRAINT DF_MSIGN_Signing_Type DEFAULT(N'sign'),
  SignatureType NVARCHAR(32) NOT NULL, OperationStatus NVARCHAR(24) NOT NULL CONSTRAINT DF_MSIGN_Signing_Status DEFAULT(N'queued'),
  InputSha256 BINARY(32) NULL, OutputSha256 BINARY(32) NULL,
  InputFileSizeBytes BIGINT NULL, OutputFileSizeBytes BIGINT NULL,
  BridgeVersion NVARCHAR(64) NULL, CspVersion NVARCHAR(64) NULL,
  MachineName NVARCHAR(256) NULL, WindowsSid NVARCHAR(184) NULL,
  StartedAt DATETIME2(3) NULL, CompletedAt DATETIME2(3) NULL,
  ErrorCode NVARCHAR(128) NULL, ErrorMessage NVARCHAR(2000) NULL,
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Signing_Created DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT UQ_MSIGN_Signing_Public UNIQUE(OperationPublicId),
  CONSTRAINT FK_MSIGN_Signing_Document FOREIGN KEY(DocumentId) REFERENCES MSIGN.Documents(DocumentId),
  CONSTRAINT FK_MSIGN_Signing_User FOREIGN KEY(UserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT FK_MSIGN_Signing_Cert FOREIGN KEY(CertificateId) REFERENCES MSIGN.Certificates(CertificateId),
  CONSTRAINT CK_MSIGN_Signing_Type CHECK(SignatureType IN(N'cades-bes-detached',N'cades-bes-attached')),
  CONSTRAINT CK_MSIGN_Signing_Status CHECK(OperationStatus IN(N'queued',N'running',N'succeeded',N'failed',N'cancelled'))
 );
 CREATE INDEX IX_MSIGN_Signing_Document ON MSIGN.SigningOperations(DocumentId,CreatedAt DESC);
 CREATE INDEX IX_MSIGN_Signing_User ON MSIGN.SigningOperations(UserId,CreatedAt DESC);
END;
GO
IF OBJECT_ID(N'MSIGN.Signatures',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.Signatures(
  SignatureId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_Signatures PRIMARY KEY,
  SigningOperationId BIGINT NOT NULL, SignatureFormat NVARCHAR(32) NOT NULL CONSTRAINT DF_MSIGN_Signatures_Format DEFAULT(N'CAdES-BES'),
  IsDetached BIT NOT NULL, SignatureFileName NVARCHAR(512) NULL,
  SignatureStorageUri NVARCHAR(2048) NULL, SignatureData VARBINARY(MAX) NULL,
  SignatureSha256 BINARY(32) NULL, SignatureSizeBytes BIGINT NULL,
  SignerThumbprint CHAR(40) NULL, SignerSubject NVARCHAR(1024) NULL, SignedAt DATETIME2(3) NULL,
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Signatures_Created DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT FK_MSIGN_Signatures_Operation FOREIGN KEY(SigningOperationId) REFERENCES MSIGN.SigningOperations(SigningOperationId),
  CONSTRAINT CK_MSIGN_Signatures_Location CHECK((SignatureStorageUri IS NOT NULL AND SignatureData IS NULL) OR (SignatureStorageUri IS NULL AND SignatureData IS NOT NULL) OR (SignatureStorageUri IS NULL AND SignatureData IS NULL))
 );
 CREATE INDEX IX_MSIGN_Signatures_Operation ON MSIGN.Signatures(SigningOperationId);
END;
GO
IF OBJECT_ID(N'MSIGN.SignatureVerifications',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.SignatureVerifications(
  VerificationId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_Verifications PRIMARY KEY,
  SignatureId BIGINT NOT NULL, VerifiedByUserId BIGINT NULL,
  VerificationStatus NVARCHAR(24) NOT NULL, CryptographicValid BIT NULL, CadesProfileValid BIT NULL,
  CertificateTimeValid BIT NULL, ChainTrusted BIT NULL, RevocationStatus NVARCHAR(24) NULL,
  TimestampStatus NVARCHAR(24) NULL, SignerThumbprint CHAR(40) NULL,
  StatusCode NVARCHAR(128) NULL, StatusMessage NVARCHAR(2000) NULL,
  VerificationDetailsJson NVARCHAR(MAX) NULL,
  VerifiedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Verifications_Time DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT FK_MSIGN_Verifications_Signature FOREIGN KEY(SignatureId) REFERENCES MSIGN.Signatures(SignatureId),
  CONSTRAINT FK_MSIGN_Verifications_User FOREIGN KEY(VerifiedByUserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT CK_MSIGN_Verifications_Json CHECK(VerificationDetailsJson IS NULL OR ISJSON(VerificationDetailsJson)=1)
 );
 CREATE INDEX IX_MSIGN_Verifications_Signature ON MSIGN.SignatureVerifications(SignatureId,VerifiedAt DESC);
END;
GO
IF OBJECT_ID(N'MSIGN.NetrikaTasks',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.NetrikaTasks(
  NetrikaTaskId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_NetrikaTasks PRIMARY KEY,
  TaskPublicId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MSIGN_Netrika_Public DEFAULT(NEWSEQUENTIALID()),
  ExternalTaskId NVARCHAR(256) NULL, PatientId NVARCHAR(128) NOT NULL,
  PatientDisplayName NVARCHAR(256) NULL, CreatedByUserId BIGINT NOT NULL,
  TaskStatus NVARCHAR(32) NOT NULL CONSTRAINT DF_MSIGN_Netrika_Status DEFAULT(N'draft'),
  IdempotencyKey NVARCHAR(128) NULL, RequestPayloadJson NVARCHAR(MAX) NULL,
  LastResponseJson NVARCHAR(MAX) NULL, LastErrorCode NVARCHAR(128) NULL,
  LastErrorMessage NVARCHAR(2000) NULL, AttemptCount INT NOT NULL CONSTRAINT DF_MSIGN_Netrika_Attempts DEFAULT(0),
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Netrika_Created DEFAULT(SYSUTCDATETIME()),
  SentAt DATETIME2(3) NULL, CompletedAt DATETIME2(3) NULL,
  UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Netrika_Updated DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT UQ_MSIGN_Netrika_Public UNIQUE(TaskPublicId),
  CONSTRAINT FK_MSIGN_Netrika_User FOREIGN KEY(CreatedByUserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT CK_MSIGN_Netrika_Status CHECK(TaskStatus IN(N'draft',N'prepared',N'sending',N'sent',N'awaiting-signature',N'partially-signed',N'completed',N'rejected',N'cancelled',N'error')),
  CONSTRAINT CK_MSIGN_Netrika_Attempts CHECK(AttemptCount>=0),
  CONSTRAINT CK_MSIGN_Netrika_RequestJson CHECK(RequestPayloadJson IS NULL OR ISJSON(RequestPayloadJson)=1),
  CONSTRAINT CK_MSIGN_Netrika_ResponseJson CHECK(LastResponseJson IS NULL OR ISJSON(LastResponseJson)=1)
 );
 CREATE UNIQUE INDEX UX_MSIGN_Netrika_Idempotency ON MSIGN.NetrikaTasks(IdempotencyKey) WHERE IdempotencyKey IS NOT NULL;
 CREATE INDEX IX_MSIGN_Netrika_Patient ON MSIGN.NetrikaTasks(PatientId,CreatedAt DESC);
END;
GO
IF OBJECT_ID(N'MSIGN.NetrikaTaskDocuments',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.NetrikaTaskDocuments(
  NetrikaTaskDocumentId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_NetrikaTaskDocuments PRIMARY KEY,
  NetrikaTaskId BIGINT NOT NULL, DocumentId BIGINT NOT NULL,
  ExternalDocumentId NVARCHAR(256) NULL,
  ItemStatus NVARCHAR(32) NOT NULL CONSTRAINT DF_MSIGN_NetrikaItem_Status DEFAULT(N'pending'),
  ExternalStatus NVARCHAR(128) NULL, LastStatusAt DATETIME2(3) NULL,
  SignedDocumentUri NVARCHAR(2048) NULL, ErrorMessage NVARCHAR(2000) NULL,
  CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_NetrikaItem_Created DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT FK_MSIGN_NetrikaItem_Task FOREIGN KEY(NetrikaTaskId) REFERENCES MSIGN.NetrikaTasks(NetrikaTaskId),
  CONSTRAINT FK_MSIGN_NetrikaItem_Document FOREIGN KEY(DocumentId) REFERENCES MSIGN.Documents(DocumentId),
  CONSTRAINT UQ_MSIGN_NetrikaTaskDocuments UNIQUE(NetrikaTaskId,DocumentId)
 );
 CREATE INDEX IX_MSIGN_NetrikaItems_Status ON MSIGN.NetrikaTaskDocuments(ItemStatus,LastStatusAt);
END;
GO
IF OBJECT_ID(N'MSIGN.AuditLog',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.AuditLog(
  AuditId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_AuditLog PRIMARY KEY,
  EventId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MSIGN_Audit_Event DEFAULT(NEWSEQUENTIALID()),
  UserId BIGINT NULL, EventType NVARCHAR(128) NOT NULL,
  EntityType NVARCHAR(64) NULL, EntityId NVARCHAR(128) NULL,
  Outcome NVARCHAR(24) NOT NULL, DetailsJson NVARCHAR(MAX) NULL,
  MachineName NVARCHAR(256) NULL, WindowsSid NVARCHAR(184) NULL,
  CorrelationId UNIQUEIDENTIFIER NULL,
  OccurredAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Audit_Time DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT UQ_MSIGN_Audit_Event UNIQUE(EventId),
  CONSTRAINT FK_MSIGN_Audit_User FOREIGN KEY(UserId) REFERENCES MSIGN.Users(UserId),
  CONSTRAINT CK_MSIGN_Audit_Outcome CHECK(Outcome IN(N'success',N'failure',N'denied',N'info')),
  CONSTRAINT CK_MSIGN_Audit_Json CHECK(DetailsJson IS NULL OR ISJSON(DetailsJson)=1)
 );
 CREATE INDEX IX_MSIGN_Audit_Time ON MSIGN.AuditLog(OccurredAt DESC);
 CREATE INDEX IX_MSIGN_Audit_User ON MSIGN.AuditLog(UserId,OccurredAt DESC);
 CREATE INDEX IX_MSIGN_Audit_Entity ON MSIGN.AuditLog(EntityType,EntityId) WHERE EntityId IS NOT NULL;
END;
GO
IF OBJECT_ID(N'MSIGN.IntegrationSettings',N'U') IS NULL
BEGIN
 CREATE TABLE MSIGN.IntegrationSettings(
  IntegrationSettingId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MSIGN_IntegrationSettings PRIMARY KEY,
  IntegrationCode NVARCHAR(64) NOT NULL, SettingKey NVARCHAR(128) NOT NULL,
  SettingValue NVARCHAR(2000) NULL, IsSecretReference BIT NOT NULL CONSTRAINT DF_MSIGN_Settings_Secret DEFAULT(0),
  IsEnabled BIT NOT NULL CONSTRAINT DF_MSIGN_Settings_Enabled DEFAULT(0),
  EnvironmentName NVARCHAR(32) NOT NULL CONSTRAINT DF_MSIGN_Settings_Env DEFAULT(N'production'),
  UpdatedByUserId BIGINT NULL,
  UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_MSIGN_Settings_Updated DEFAULT(SYSUTCDATETIME()),
  CONSTRAINT UQ_MSIGN_IntegrationSettings UNIQUE(IntegrationCode,SettingKey,EnvironmentName),
  CONSTRAINT FK_MSIGN_Settings_User FOREIGN KEY(UpdatedByUserId) REFERENCES MSIGN.Users(UserId)
 );
END;
GO
PRINT N'MSIGN schema deployment completed.';
