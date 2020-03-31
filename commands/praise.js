const Discord = require('discord.js');
const log = require('../utils/log.js');
const config = require('../utils/config.js');

const options = {
	name: 'praise',
	description: 'Praise be!',
};

async function execute(message, args) {

	log.info("Praising");

	const embed = new Discord.MessageEmbed().setColor(config.colors.success)
		.setTitle("Praises: coming soon");
	message.channel.send(embed);
}

module.exports = options;
module.exports.execute = execute;
