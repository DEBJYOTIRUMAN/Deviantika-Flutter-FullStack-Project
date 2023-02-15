import mongoose from "mongoose";
const Schema = mongoose.Schema;
import { APP_URL } from "../config";

const courseSchema = new Schema(
  {
    name: { type: String, required: true },
    caption: { type: String, required: true },
    duration: { type: String, required: true },
    instructors: { type: String, required: true },
    rating: { type: Number, required: true },
    likes: { type: Array, required: true },
    image_url: {
      type: String,
      required: true,
      get: (image) => {
        return `${APP_URL}/${image.replace("\\", "/")}`;
      },
    },
  },
  { timestamps: true, toJSON: { getters: true }, id: false }
);

export default mongoose.model("Course", courseSchema, "courses");
