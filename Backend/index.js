import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.js';
import petsRoutes from './routes/pets.js';
import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/pets', petsRoutes);

async function start() {
  const mongoUri = process.env.MONGODB_URI;
  try {
    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB');
    app.listen(PORT, () => {
      console.log(`Adopto backend listening on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Failed to connect to MongoDB', err);
    process.exit(1);
  }
}

start();
