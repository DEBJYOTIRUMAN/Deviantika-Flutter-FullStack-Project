import Joi from 'joi';
const audiobookSchema = Joi.object({
    title: Joi.string().required(),
    authors: Joi.string().required(),
    rating: Joi.number().required(),
    genre: Joi.string().required(),
    recommend: Joi.boolean().required(),
});
export default audiobookSchema;