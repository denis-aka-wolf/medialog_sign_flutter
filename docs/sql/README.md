# Medialog Sign database scripts

SQL Server scripts for the application-owned MSIGN schema. They do not modify native Medialog tables.

## Deployment order

1. Back up the target database and test against a non-production copy.
2. Execute 001_schema.sql using an account allowed to create schemas and tables.
3. Optionally execute 002_security.sql, create a dedicated SQL login/user, and add it to MSIGN_AppRole.
4. Verify object creation and test with a least-privilege application account.

The scripts are idempotent for initial installation: existing tables are not altered. For later changes, add versioned migration scripts rather than editing a migration already deployed.

## Tables

| Table | Purpose |
|---|---|
| Users | Application users linked to Medialog by an external identifier |
| Certificates | Public certificate metadata |
| UserCertificates | User-to-certificate assignments |
| Documents | Document metadata, patient reference, SHA-256 and storage location |
| SigningOperations | Attempts and outcomes of signing operations |
| Signatures | CAdES signature artifact metadata and optional payload |
| SignatureVerifications | Separate cryptographic, chain, revocation and timestamp results |
| NetrikaTasks | Outbound workflow and remote task state |
| NetrikaTaskDocuments | Per-document state inside a Netrika task |
| AuditLog | Append-only application audit events |
| IntegrationSettings | Non-secret integration configuration and secret references |

## Integration notes

- MedialogUserId, PatientId, MedialogEntityId and Netrika remote IDs are external identifiers. Confirm their actual types and mapping rules against the Medialog and Netrika interfaces before production.
- The current CryptoPro bridge reads CurrentUser/My for the Windows identity running the process. A database row does not grant access to a private key.
- Store only public certificate data. Never store private keys, key containers, PINs or passwords in these tables, logs, JSON payloads or settings.
- Prefer file/object storage for source documents and signature files. Store immutable SHA-256 hashes, byte sizes and protected storage URIs in SQL. SignatureData is optional for deployments that deliberately choose database BLOB storage.
- Successful cryptographic verification is not equivalent to trusted certificate-chain validation. Record chain trust, revocation, timestamp trust and policy acceptance separately.
- The current Flutter prototype and CryptoPro bridge do not yet implement SQL persistence or a Netrika API client. These tables describe the target design, not already-operational workflows.
- Sanitize request/response JSON and audit details. Do not persist authentication tokens, secrets, PINs, full document contents or unnecessary patient data.

## Before production

Confirm SQL Server version/collation, Medialog user and patient identifiers, Netrika API contract, document retention policy, storage encryption and ACLs, backup/restore, audit retention, and the exact permissions required by the application. Apply scripts first to a restored test database and validate foreign keys, indexes and query plans.
