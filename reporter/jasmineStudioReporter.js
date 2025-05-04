function JasmineStudioReporter(log = console.log) {
	this._log = log;
}

const eventNames = ['jasmineDone', 'jasmineStarted', 'specDone', 'specStarted',
	'suiteDone', 'suiteStarted'];

for (const eventName of eventNames) {
	JasmineStudioReporter.prototype[eventName] = function(payload) {
		// Report the event on one line, with a recognizable prefix that is
		// unlikely to also occur in console.log/console.error calls caused by
		// the test suite. This allows the consumer to differentiate between
		// reporter output and test output, and also infer which test caused each
		// output line.
		// *Very* loosely based on the Teamcity protocol used by IntelliJ test
		// runners.
		this._log('##jasmineStudio:' + JSON.stringify({eventName, payload}));
	};
}


module.exports = JasmineStudioReporter;
