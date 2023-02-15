import express from "express";
const router = express.Router();
import {
  registerController,
  loginController,
  userController,
  refreshController,
  courseController,
  videoController,
  audiobookController,
} from "../controllers";
import auth from "../middlewares/auth";
import admin from '../middlewares/admin';

// Login Routes
router.post("/register", registerController.register);
router.post("/login", loginController.login);
router.get("/me", auth, userController.me);
router.post("/refresh", refreshController.refresh);
router.post("/logout", auth, loginController.logout);

// Course Routes
router.post('/course', [auth, admin], courseController.store);
router.put('/course/:id', [auth, admin], courseController.update);
router.delete('/course/:id', [auth, admin], courseController.destroy);
router.get('/course', auth, courseController.index);
router.get('/course/:name', auth, courseController.searchCourse);
router.put('/course/like/:courseId', auth, courseController.likeCourse);

//Video Routes
router.post("/video", [auth, admin], videoController.storeVideo);
router.put("/video/:videoId", [auth, admin], videoController.updateVideo);
router.delete("/video/:videoId", [auth, admin], videoController.deleteVideo);
router.get("/video/course/:course", auth, videoController.courseVideos);
router.get("/video/:id", videoController.streamingVideo);

//AudioBook Routes
router.post("/audiobook", [auth, admin], audiobookController.storeAudiobook);
router.put("/audiobook/:audiobookId", [auth, admin], audiobookController.updateAudiobook);
router.delete("/audiobook/:audiobookId", [auth, admin], audiobookController.deleteAudiobook);
router.get("/audiobook", auth, audiobookController.getAudiobooks);
router.put("/audiobook/like/:audiobookId", auth, audiobookController.likeAudiobook);
router.get("/audiobook/search/:title", auth, audiobookController.searchAudiobook);
router.get("/audiobook/:id", audiobookController.streamingAudiobook);
export default router;
