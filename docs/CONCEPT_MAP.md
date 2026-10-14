# Concept Map

| Learned concept | Project implementation |
|---|---|
| Module | `AuthModule`, `UsersModule`, `AppModule` |
| Controller | `AuthController`, `UsersController` |
| Provider | Services/guards registered in modules |
| Service | `AuthService`, `UsersService` |
| Dependency Injection | Constructors in controllers/services/guards |
| DTO | Register/Login/Refresh/Role DTOs |
| Pipe | Global `ValidationPipe` |
| Guard | `JwtAuthGuard`, `RolesGuard` |
| Interceptor | `LoggingInterceptor` |
| Exception Filter | `HttpExceptionFilter` |
| Middleware | `RequestIdMiddleware` |
| Configuration | `ConfigModule` + `.env` |
| Database | TypeORM + MySQL |
| Authentication | Register/login/JWT |
| Authorization | RolesGuard |
| Password hashing | bcrypt |
| Access token | JWT, short TTL |
| Refresh token | JWT, hashed in DB |
| Secure storage | Flutter Secure Storage |
| Protected API | `/users/me` |
| Role protected API | `GET /users`, `PATCH /users/:id/role` |
