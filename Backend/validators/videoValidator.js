import Joi from 'joi';
const videoSchema = Joi.object({
    title: Joi.string().required(),
    time: Joi.string().required(),
    language: Joi.string().required(),
    course: Joi.string().required(),
});
export default videoSchema;