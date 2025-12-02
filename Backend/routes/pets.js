import { Router } from 'express';
import Pet from '../models/pet.js';

const router = Router();

// GET /api/pets - list pets
router.get('/', async (req, res) => {
  try {
    const pets = await Pet.find().lean().sort({ createdAt: -1 });
    res.json(pets);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to fetch pets' });
  }
});

// POST /api/pets - create pet
router.post('/', async (req, res) => {
  try {
    const { name, breed, category, age, gender, image } = req.body;
    if (!name) return res.status(400).json({ message: 'Name required' });
    const pet = new Pet({ name, breed, category, age, gender, image });
    await pet.save();
    res.status(201).json(pet);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to create pet' });
  }
});

export default router;
