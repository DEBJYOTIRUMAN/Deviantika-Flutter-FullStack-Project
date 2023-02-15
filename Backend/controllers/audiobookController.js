import { AudioBook } from "../models";
import multer from "multer";
import path from "path";
import fs from "fs";
import CustomErrorHandler from "../services/CustomErrorHandler";
import audiobookSchema from "../validators/audiobookValidator";
import Joi from "joi";
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "audiobook/"),
  filename: (req, file, cb) => {
    if (file.fieldname === "thumbnail") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
    if (file.fieldname === "thumbnailCover") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
    if (file.fieldname === "audio") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
  },
});
const handleMultipartData = multer({
  storage,
  limits: { fileSize: 10000000 * 10 },
}).fields([
  {
    name: "thumbnail",
    maxCount: 1,
  },
  {
    name: "thumbnailCover",
    maxCount: 1,
  },
  {
    name: "audio",
    maxCount: 1,
  },
]); // 100MB

const audiobookController = {
  async storeAudiobook(req, res, next) {
    handleMultipartData(req, res, async (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError(err.message));
      }
      const thumbnailPath = req.files.thumbnail[0].path;
      const thumbnailCoverPath = req.files.thumbnailCover[0].path;
      const audioPath = req.files.audio[0].path;
      // Validation
      const { error } = audiobookSchema.validate(req.body);

      if (error) {
        // Delete Thumbnail
        fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });
        // Delete Thumbnail Cover
        fs.unlink(`${appRoot}/${thumbnailCoverPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });
        // Delete Audio
        fs.unlink(`${appRoot}/${audioPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });

        return next(error);
      }

      const { title, authors, rating, genre, recommend } = req.body;

      let document;
      try {
        document = await AudioBook.create({
          title: title,
          authors: authors,
          rating: rating,
          genre: genre,
          thumbnail: thumbnailPath,
          thumbnailCover: thumbnailCoverPath,
          audio: audioPath,
          likes: [],
          recommend: recommend,
        });
      } catch (err) {
        return next(err);
      }
      res.status(201).json(document);
    });
  },

  async updateAudiobook(req, res, next) {
    handleMultipartData(req, res, async (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError(err.message));
      }

      let thumbnailPath, thumbnailCoverPath, audioPath;
      if (req.files.thumbnail) {
        thumbnailPath = req.files.thumbnail[0].path;
      }
      if (req.files.thumbnailCover) {
        thumbnailCoverPath = req.files.thumbnailCover[0].path;
      }
      if (req.files.audio) {
        audioPath = req.files.audio[0].path;
      }

      //Validation
      const { error } = audiobookSchema.validate(req.body);
      if (error) {
        // Delete Thumbnail
        if (req.files.thumbnail) {
          fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }
        // Delete Thumbnail Cover
        if (req.files.thumbnailCover) {
          fs.unlink(`${appRoot}/${thumbnailCoverPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }
        // Delete Audio
        if (req.files.audio) {
          fs.unlink(`${appRoot}/${audioPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }

        return next(error);
      }

      const { title, authors, rating, genre, recommend } = req.body;
      let document;
      try {
        document = await AudioBook.findOneAndUpdate(
          { _id: req.params.audiobookId },
          {
            title: title,
            authors: authors,
            rating: rating,
            genre: genre,
            ...(req.files.thumbnail && { thumbnail: thumbnailPath }),
            ...(req.files.thumbnailCover && {
              thumbnailCover: thumbnailCoverPath,
            }),
            ...(req.files.audio && { audio: audioPath }),
            recommend: recommend,
          },
          { new: true }
        );
      } catch (err) {
        return next(err);
      }
      res.status(201).json(document);
    });
  },

  async deleteAudiobook(req, res, next) {
    const document = await AudioBook.findOneAndRemove({
      _id: req.params.audiobookId,
    });
    if (!document) {
      return next(new Error("Nothing to delete"));
    }
    const thumbnailPath = document._doc.thumbnail;
    const thumbnailCoverPath = document._doc.thumbnailCover;
    const audioPath = document._doc.audio;
    // Delete Thumbnail
    fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    // Delete Thumbnail Cover
    fs.unlink(`${appRoot}/${thumbnailCoverPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    // Delete Audio File
    fs.unlink(`${appRoot}/${audioPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });

    res.json(document);
  },

  async getAudiobooks(req, res, next) {
    let documents;
    try {
      documents = await AudioBook.find()
        .select("-updatedAt -__v")
        .sort({ createdAt: -1 });
    } catch (err) {
      return next(CustomErrorHandler.serverError());
    }

    return res.json(documents);
  },

  async likeAudiobook(req, res, next) {
    const likeAudiobookSchema = Joi.object({
      likes: Joi.array().required(),
    });

    const { error } = likeAudiobookSchema.validate(req.body);
    if (error) {
      return next(error);
    }

    const { likes } = req.body;
    //Update Likes
    let document;
    try {
      document = await AudioBook.findOneAndUpdate(
        { _id: req.params.audiobookId },
        {
          likes: likes,
        },
        { new: true }
      );
    } catch (err) {
      return next(err);
    }
    res.status(201).json(document);
  },

  async searchAudiobook(req, res, next) {
    let document;
    try {
      document = await AudioBook.find({
        title: { $regex: req.params.title, $options: "i" },
      }).select("-updatedAt -__v");
    } catch (err) {
      return next(CustomErrorHandler.serverError());
    }
    return res.json(document);
  },
  async streamingAudiobook(req, res, next) {
    const audioPath = `audiobook/${req.params.id}`;
    const audioStat = fs.statSync(audioPath);
    const fileSize = audioStat.size;
    const audioRange = req.headers.range;
    if (audioRange) {
      const parts = audioRange.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = end - start + 1;
      const file = fs.createReadStream(audioPath, { start, end });
      const head = {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize,
        'Content-Type': 'audio/mpeg',
      };
      res.writeHead(206, head);
      file.pipe(res);
    } else {
      const head = {
        "Content-Length": fileSize,
        'Content-Type': 'audio/mpeg',
      };
      res.writeHead(200, head);
      fs.createReadStream(audioPath).pipe(res);
    }
  },
};
export default audiobookController;
