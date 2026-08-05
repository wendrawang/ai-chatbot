# Security boundary

This repository is intentionally sanitized.

Do not add:

- production or internal endpoints;
- certificates, private keys, profiles, or credentials;
- access tokens, API keys, or session material;
- proprietary host-application source code;
- customer or employee data;
- internal project, service, or environment identifiers.

The package owns feature behavior and UI. The host application owns transport
security, authentication, authorization, secure storage, and transaction
execution. PIN values must never enter chat messages, persistence, analytics,
logs, crash reports, or streaming payloads.
