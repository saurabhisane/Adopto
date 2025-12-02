import mongoose from 'mongoose';

const petSchema = new mongoose.Schema({
  name: { type: String, required: true },
  breed: { type: String },
  age: { type: String },
  category: { type: String },
  gender: { type: String },
  image: { type: String },
}, { timestamps: true });

export default mongoose.model('Pet', petSchema);
