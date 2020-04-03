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

	for (let rolename of args) {
		rolename = rolename.toLowerCase();
		let add = true;

		if (!(rolename.startsWith('cs') || rolename.startsWith('ece'))) {
			rolename = 'cs' + rolename;
		}

		if (rolename.endsWith('+')) {
			rolename = rolename.slice(0, -1);
		}
		if (rolename.endsWith('-')) {
			add = false;
			rolename = rolename.slice(0, -1);
		}

		const roleid = config.classroles[`${rolename}`];
		// ignore args that are not valid roles
		if (roleid == undefined) { continue; }

		if (add) { message.member.roles.add(roleid); }
		else { message.member.roles.remove(roleid); }
	}

	message.delete();
}

module.exports = options;
module.exports.execute = execute;
