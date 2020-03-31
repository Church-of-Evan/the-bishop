const c = require('chalk');
const config = require('./config.js');

function strHeader(type) {
	const d = new Date();
	let str;

	switch (type) {
	case 'START':
		str = c.cyan(type);
		break;
	case 'INFO':
		str = c.green(type);
		break;
	case 'WARN':
		str = c.yellow(type);
		break;
	case 'ERR!':
		str = c.red(type);
		break;
	default:
		str = c.grey(type);
	}

	return "[ " + c.grey(d.toLocaleString()) + " | " + str + " ]";
}

function start(message) { if (config.loglevel > 0) console.log(strHeader('START'), message); }
function err(message) { if (config.loglevel > 1) console.log(strHeader('ERR!'), message); }
function warn(message) { if (config.loglevel > 2) console.log(strHeader('WARN'), message); }
function info(message) { if (config.loglevel > 3) console.log(strHeader('INFO'), message); }


module.exports.start = start;
module.exports.err = err;
module.exports.warn = info;
module.exports.info = info;
