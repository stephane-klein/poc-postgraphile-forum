const axios = require('axios');
const sendMailUrl = process.env.SEND_MAIL_API;

module.exports = async ({ from, to, firstname }) => {
    console.log(`Sendmail ${from} ${to} ${firstname}`);

    try {
        const response = await axios.post(
            `${sendMailUrl}/v1/templates/welcome/send`,
            {
                from: from,
                to: to,
                firstname: firstname
            }
        );
        console.log(response.status);
    } catch (error) {
        console.error(error);
    }
};