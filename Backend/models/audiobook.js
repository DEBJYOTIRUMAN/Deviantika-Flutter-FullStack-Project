import mongoose from "mongoose";
const Schema = mongoose.Schema;
import { APP_URL } from "../config";

const audiobookSchema = new Schema(
  {
    title: { type: String, required: true },
    authors: { type: String, required: true },
    rating: { type: Number, required: true },
    genre: { type: String, required: true },
    thumbnail: {
        type: String,
        required: true,
        get: (thumbnail) => {
          return `${APP_URL}/${thumbnail.replace("\\", "/")}`;
        },
      },
    thumbnailCover: {
        type: String,
        required: true,
        get: (thumbnailCover) => {
          return `${APP_URL}/${thumbnailCover.replace("\\", "/")}`;
        },
      },
    audio: {
      type: String,
      required: true,
      get: (audio) => {
        return `${APP_URL}/${audio.replace("\\", "/")}`;
      },
    },
    likes: { type: Array, required: true },
    recommend: { type: Boolean, required: true },
  },
  { timestamps: true, toJSON: { getters: true }, id: false }
);

export default mongoose.model("AudioBook", audiobookSchema, "audiobooks");
