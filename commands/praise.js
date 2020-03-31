const Discord = require('discord.js');
const log = require('../utils/log.js');

const options = {
	name: 'praise',
	description: 'Praise be!',
};

async function execute(message, args) {
	const config = message.client.config;

	log.info("Praising");

	const embed = new Discord.MessageEmbed().setColor(config.color.success)
		.setTitle("Praises: coming soon");
	message.channel.send(embed);
}

module.exports = options;
module.exports.execute = execute;
