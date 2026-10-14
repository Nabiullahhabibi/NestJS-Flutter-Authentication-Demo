# NestJS Auth API

A learning backend for Phase 13: NestJS + Authentication.

## Concepts implemented

- Modules, Controllers, Providers, Services, Dependency Injection
- DTOs + class-validator ValidationPipe
- Guards: JWT authentication and role authorization
- Interceptor: request timing/logging
- Exception Filter: consistent HTTP errors
- Middleware: request ID
- Configuration via environment variables
- TypeORM + MySQL integration
- Register/login/logout/refresh
- bcrypt password hashing
- Access + refresh JWTs
- Refresh-token hashing/revocation
- Protected `/users/me`
- Admin-only user listing and role update

## Architecture

`Request -> Middleware -> Guard -> Pipe -> Controller -> Service -> Repository/ORM -> MySQL`

## Run

1. Copy `.env.example` to `.env`.
2. Start MySQL: `docker compose up -d`.
3. Install: `npm install`.
4. Start: `npm run start:dev`.

The API runs on `http://localhost:3000`.

For a physical Android device, replace `localhost` in the Flutter API URL with the computer's LAN IP address.

## Important learning note

`TypeORM synchronize` is enabled only outside production for this demo. A production system should use reviewed migrations instead.



==============================================================

Backend source files and responsibilities
- src/main.ts — starts the NestJS server and configures request validation, error formatting, request logging, and CORS.
- src/app.module.ts — root module; loads config, connects TypeORM to MySQL, registers the User entity, and imports the auth and users modules.
- src/config/configuration.ts — reads port, database, and JWT settings from environment variables.
- src/auth/auth.module.ts — wires together authentication controller, service, JWT support, and the users module.
- src/auth/auth.controller.ts — declares the authentication routes.
- src/auth/auth.service.ts — registers and authenticates accounts, hashes passwords and refresh tokens, issues tokens, and handles refresh/logout.
- src/auth/guards/jwt-auth.guard.ts — verifies the access token and loads the user’s current role from the database.
- src/auth/strategies/jwt.strategy.ts — small JWT service; the guard performs the actual verification in this project.
- src/auth/dto/login.dto.ts — validates login input.
- src/auth/dto/register.dto.ts — validates and normalizes registration input.
- src/auth/dto/refresh-token.dto.ts — validates the refresh-token request.
- src/auth/dto/logout.dto.ts — validates logout token input; the current logout controller does not use this DTO.
- src/users/users.module.ts — registers the user entity with TypeORM and provides the user service and access guards.
- src/users/users.controller.ts — declares profile, admin user-list, and role-update routes; applies authentication and admin authorization.
- src/users/users.service.ts — reads and writes user records and removes password and refresh-token hashes from list responses.
- src/users/entities/user.entity.ts — defines the MySQL users table fields and the USER/ADMIN roles.
- src/users/dto/update-role.dto.ts — validates a requested role change.
- src/common/guards/roles.decorator.ts — marks routes with the role they require.
- src/common/guards/roles.guard.ts — enforces those role requirements.
- src/common/middleware/request-id.middleware.ts — assigns or forwards a request ID.
- src/common/interceptors/logging.interceptor.ts — logs completed HTTP requests and timing.
- src/common/filters/http-exception.filter.ts — returns errors in a consistent JSON format.