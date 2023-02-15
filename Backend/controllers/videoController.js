import { Video } from "../models";
import multer from "multer";
import path from "path";
import fs from "fs";
import CustomErrorHandler from "../services/CustomErrorHandler";
import videoSchema from "../validators/videoValidator";
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => {
    if (file.fieldname === "video") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
    if (file.fieldname === "thumbnail") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
  },
});
const handleMultipartData = multer({
  storage,
  limits: { fileSize: 2000000000 },
}).fields([
  {
    name: "video",
    maxCount: 1,
  },
  {
    name: "thumbnail",
    maxCount: 1,
  },
]); // 2GB

const handleThumbnail = multer({
  storage,
  limits: { fileSize: 1000000 * 5 },
}).single("thumbnail"); // 5MB

const videoController = {
  async storeVideo(req, res, next) {
    handleMultipartData(req, res, async (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError(err.message));
      }
      const videoPath = req.files.video[0].path;
      const thumbnailPath = req.files.thumbnail[0].path;
      // Validation
      const { error } = videoSchema.validate(req.body);

      if (error) {
        // Delete Video
        fs.unlink(`${appRoot}/${videoPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });
        // Delete Thumbnail
        fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });
        return next(error);
      }

      const { title, time, language, course } = req.body;

      let document;
      try {
        document = await Video.create({
          title: title,
          time: time,
          language: language,
          course: course,
          videoUrl: videoPath,
          thumbnail: thumbnailPath,
        });
      } catch (err) {
        return next(err);
      }
      res.status(201).json(document);
    });
  },

  async updateVideo(req, res, next) {
    handleThumbnail(req, res, async (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError(err.message));
      }

      let thumbnailPath;
      if (req.file) {
        thumbnailPath = req.file.path;
      }
      // Validation
      const { error } = videoSchema.validate(req.body);
      if (error) {
        // Delete the uploaded file
        if (req.file) {
          fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }
        return next(error);
      }

      const { title, time, language, course } = req.body;
      let document;
      try {
        document = await Video.findOneAndUpdate(
          { _id: req.params.videoId },
          {
            title: title,
            time: time,
            language: language,
            course: course,
            ...(req.file && { thumbnail: thumbnailPath }),
          },
          { new: true }
        );
      } catch (err) {
        return next(err);
      }
      res.status(201).json(document);
    });
  },

  async deleteVideo(req, res, next) {
    const document = await Video.findOneAndRemove({ _id: req.params.videoId });
    if (!document) {
      return next(new Error("Nothing to delete"));
    }
    const videoPath = document._doc.videoUrl;
    const thumbnailPath = document._doc.thumbnail;
    // Delete Video
    fs.unlink(`${appRoot}/${videoPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    // Delete Thumbnail
    fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    res.json(document);
  },

  async courseVideos(req, res, next) {
    let documents;
    try {
      documents = await Video.find({
        course: req.params.course,
      }).select("-updatedAt -__v");
    } catch (err) {
      return next(CustomErrorHandler.serverError());
    }
    return res.json(documents);
  },

  async streamingVideo(req, res, next) {
    const videoPath = `uploads/${req.params.id}`;
    const videoStat = fs.statSync(videoPath);
    const fileSize = videoStat.size;
    const videoRange = req.headers.range;
    if (videoRange) {
      const parts = videoRange.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = end - start + 1;
      const file = fs.createReadStream(videoPath, { start, end });
      const head = {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize,
        "Content-Type": "video/mp4",
      };
      res.writeHead(206, head);
      file.pipe(res);
    } else {
      const head = {
        "Content-Length": fileSize,
        "Content-Type": "video/mp4",
      };
      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }
  },
};
export default videoController;
