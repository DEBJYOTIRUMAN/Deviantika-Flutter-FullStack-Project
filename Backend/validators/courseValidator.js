import Joi from 'joi';
const courseSchema = Joi.object({
    name: Joi.string().required(),
    caption: Joi.string().required(),
    duration: Joi.string().required(),
    instructors: Joi.string().required(),
    rating: Joi.number().required(),
    image_url: Joi.string(),
});
export default courseSchema;