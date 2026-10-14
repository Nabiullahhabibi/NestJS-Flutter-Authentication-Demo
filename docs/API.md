# API Reference

Base URL: `http://localhost:3000`

## POST /auth/register

```json
{"name":"Ahmad","email":"ahmad@example.com","password":"password123"}
```

## POST /auth/login

```json
{"email":"ahmad@example.com","password":"password123"}
```

Returns access token, refresh token, and safe user data.

## POST /auth/refresh

```json
{"refreshToken":"<refresh-token>"}
```

## POST /auth/logout

Requires `Authorization: Bearer <access-token>`.

```json
{"refreshToken":"<refresh-token>"}
```

The backend revokes the stored refresh-token hash.

## GET /users/me

Requires a valid access token.

## GET /users

Requires role `ADMIN`.

## PATCH /users/:id/role

Requires role `ADMIN`.

```json
{"role":"ADMIN"}
```

An administrator cannot change their own role through this endpoint. The
backend reloads the user's current role for every authenticated request, so
promotions and demotions take effect immediately.

### Set up the first administrator

New registrations receive the `USER` role. Since the admin endpoints require
an existing administrator, promote the first account directly in MySQL:

```sql
UPDATE users SET role = 'ADMIN' WHERE email = 'admin@example.com';
```

Then log in with that account. Keep admin promotion restricted to trusted
operators.

## Error format

```json
{
  "statusCode": 401,
  "message": "Invalid or expired access token",
  "path": "/users/me",
  "timestamp": "..."
}
```
