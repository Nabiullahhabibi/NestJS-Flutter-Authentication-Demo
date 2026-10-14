export default () => ({
  port: Number(process.env.PORT ?? 3000),
  database: {
    host: process.env.DATABASE_HOST,
    port: Number(process.env.DATABASE_PORT ?? 3306),
    username: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    name: process.env.DATABASE_NAME,
  },
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET,
    refreshSecret: process.env.JWT_REFRESH_SECRET,
    accessTtl: process.env.ACCESS_TOKEN_TTL ?? '15m',
    refreshTtl: process.env.REFRESH_TOKEN_TTL ?? '7d',
  },
});
