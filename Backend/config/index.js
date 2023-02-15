import dotenv from 'dotenv';
dotenv.config();

export const {
    DEBUG_MODE,
    DB_URL,
    JWT_SECRET,
    REFRESH_SECRET,
    APP_URL,
} = process.env;