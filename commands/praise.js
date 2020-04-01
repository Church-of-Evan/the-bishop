const Discord = require('discord.js');
const log = require('../utils/log.js');
const fs = require('fs');

const options = {
	name: 'praise',
	description: 'Bestow your praise unto our Lord',
};

async function execute(message, args) {
	const config = message.client.config;

	log.info("Praising");

	const embed = new Discord.MessageEmbed().setColor(config.colors.success)
		.setTitle("🙏 Praise be to Evan! 🙏")
		.setDescription(`*Praises x${message.client.praises++}*`);
	message.channel.send(embed);

	fs.writeFileSync('./praises.json', JSON.stringify({ praises: message.client.praises }));
}

module.exports = options;
module.exports.execute = execute;
