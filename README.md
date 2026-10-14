# Backend Mastery — NestJS + Flutter Authentication Demo

A complete learning project combining the two Phase topics:

1. NestJS architecture
2. Authentication

## Stack

- Flutter / Dart
- NestJS / TypeScript
- TypeORM
- MySQL 8
- JWT access + refresh tokens
- bcrypt
- Dio
- flutter_secure_storage
- Docker Compose for MySQL

## What this project teaches

### NestJS

Modules, controllers, providers, services, dependency injection, DTOs, validation pipes, guards, role guards, interceptors, exception filters, middleware, configuration, database integration.

### Authentication

Register, login, logout, password hashing, JWT, access tokens, refresh tokens, expiration, protected routes, roles, authorization, secure Flutter token storage, automatic refresh, HTTPS concepts.

## Folder structure

```text
backend_mastery_auth_demo/
├── README.md
├── docs/
│   ├── API.md
│   └── CONCEPT_MAP.md
├── nestjs_auth_api/
│   ├── src/
│   ├── package.json
│   ├── .env.example
│   ├── docker-compose.yml
│   └── README.md
└── flutter_auth_client/
    ├── lib/
    ├── pubspec.yaml
    └── README.md
```

## Start the backend

```bash
cd nestjs_auth_api
cp .env.example .env
docker compose up -d
npm install
npm run start:dev
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
docker compose up -d
npm install
npm run start:dev
```

## Start Flutter

```bash
cd flutter_auth_client
flutter pub get
flutter run
```

## Demo flow

```text
Flutter Register
      ↓
NestJS DTO + ValidationPipe
      ↓
AuthService
      ↓
bcrypt password hash
      ↓
TypeORM
      ↓
MySQL
```

Then login returns access + refresh tokens. Flutter stores them securely, sends the access token as `Authorization: Bearer ...`, and automatically calls `/auth/refresh` when a protected request receives 401.

## Important production notes

This is an educational project. Before production, add migrations, stronger CORS/origin policy, rate limiting, audit logging, robust refresh-token rotation/reuse detection, HTTPS, secret management, automated tests, and stronger API validation/security policies.
