import { Course } from "../models";
import multer from "multer";
import path from "path";
import fs from 'fs';
import CustomErrorHandler from "../services/CustomErrorHandler";
import courseSchema from "../validators/courseValidator";
import Joi from "joi";

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, "uploads"),
    filename: (req, file, cb) => {
        const uniqueName = `${Date.now()}-${Math.round(
            Math.random() * 1E9
        )}${path.extname(file.originalname)}`;
        
        cb(null, uniqueName);
        
    }
});
const handleMultipartData = multer({
    storage,
    limits: { fileSize: 1000000 * 5 }
}).single('image_url'); // 5mb

const courseController = {
    async store(req, res, next) {
        //Multipart form data
        handleMultipartData(req, res, async (err) =>{
            if (err) {
                return next(CustomErrorHandler.serverError(err.message));
            }
            
            const filePath = req.file.path;
            
            //Validation
            
            const { error } = courseSchema.validate(req.body);
            
            if (error) {
                // Delete the uploaded file
                fs.unlink(`${appRoot}/${filePath}`, (err) => {
                    if (err) {
                        return next(CustomErrorHandler.serverError(err.message));
                    }
                });
                return next(error);
               
            }
            
        
        const { name, caption, duration, instructors, rating } = req.body;
            let document;
            try {
                document = await Course.create({
                    name, 
                    caption, 
                    duration, 
                    instructors,
                    rating, 
                    likes: [],
                    image_url: filePath,
                });
            } catch (err) {
                return next(err);
            }
            res.status(201).json(document);

        });
    },

    update(req, res, next) {
        handleMultipartData(req, res, async (err) =>{
            if (err) {
                return next(CustomErrorHandler.serverError(err.message));
            }
            let filePath;
            if (req.file) {
                filePath = req.file.path;
            }
            
            //Validation
            
            const { error } = courseSchema.validate(req.body);
            if (error) {
                // Delete the uploaded file
                if(req.file){
                    fs.unlink(`${appRoot}/${filePath}`, (err) => {
                        if (err) {
                            return next(CustomErrorHandler.serverError(err.message));
                        }
                    });
                }
                return next(error);
               
            }
            const { name, caption, duration, instructors, rating } = req.body;
            let document;
            try {
                document = await Course.findOneAndUpdate({ _id: req.params.id }, {
                    name, 
                    caption, 
                    duration, 
                    instructors,
                    rating, 
                    ...(req.file && { image_url: filePath })
                }, { new: true });
            } catch (err) {
                return next(err);
            }
            res.status(201).json(document);

        });
    },
    async destroy(req, res, next) {
        const document = await Course.findOneAndRemove({ _id: req.params.id });
        if(!document){
            return next(new Error('Nothing to delete'));
        }
        //Image Delete
        const imagePath = document._doc.image;
        fs.unlink(`${appRoot}/${imagePath}`, (err) =>{
            if (err) {
                return next(CustomErrorHandler.serverError());
            }
        });
        res.json(document);
    },
    async index(req, res, next) {
        let documents;
        try{
            documents = await Course.find().select('-updatedAt -__v');
     
        } catch(err){
            return next(CustomErrorHandler.serverError());
        }
        return res.json(documents);
    },

    async searchCourse(req, res, next) {
        let document;
        try {
          document = await Course.find({
            name: { $regex: req.params.name, $options: "i" },
          }).select("-updatedAt -__v");
        } catch (err) {
          return next(CustomErrorHandler.serverError());
        }
        if(document.length === 0){
            try {
                document = await Course.find({
                    caption: { $regex: req.params.name, $options: "i" },
                }).select("-updatedAt -__v");
              } catch (err) {
                return next(CustomErrorHandler.serverError());
              }
        }
        return res.json(document);
    },

    async likeCourse(req, res, next) {
        const likeCourseSchema = Joi.object({
          likes: Joi.array().required(),
        });
    
        const { error } = likeCourseSchema.validate(req.body);
        if (error) {
          return next(error);
        }
    
        const { likes } = req.body;
        //Update Likes
        let document;
        try {
          document = await Course.findOneAndUpdate(
            { _id: req.params.courseId },
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
};
export default courseController;