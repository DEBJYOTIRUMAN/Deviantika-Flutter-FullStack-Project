import mongoose from "mongoose";
const Schema = mongoose.Schema;
import { APP_URL } from "../config";

const videoSchema = new Schema(
  {
    title: { type: String, required: true },
    time: { type: String, required: true },
    language: { type: String, required: true },
    course: { type: String, required: true },
    thumbnail: {
      type: String,
      required: true,
      get: (thumbnail) => {
        return `${APP_URL}/${thumbnail.replace("\\", "/")}`;
      },
    },
    videoUrl: {
        type: String,
        required: true,
        get: (video) => {
          return `${APP_URL}/${video.replace("\\", "/")}`;
        },
      },
  },
  { timestamps: true, toJSON: { getters: true }, id: false }
);

export default mongoose.model("Video", videoSchema, "videos");
