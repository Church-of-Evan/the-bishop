const Discord = require('discord.js');
const log = require('../utils/log.js');

const options = {
	name: 'role',
	description: 'Give yourself a class role',

	usage: '<class name, e.g. cs362> (<another class> ...)',

	minArgs: 1,
};

async function execute(message, args) {
	const config = message.client.config;

	log.info(`Giving role(s) ${args} to ${message.author.username}`);
	
	let ids = [];
	for (let rolename of args) {
		rolename = rolename.toLowerCase();
		const roleid = config.classroles[`${rolename}`];
		
		// ignore args that are not valid roles
		if (roleid == undefined) { continue; }
		
		ids.push(roleid);
	}
	
	message.member.roles.add(ids);
	
	message.delete();
}

module.exports = options;
module.exports.execute = execute;
