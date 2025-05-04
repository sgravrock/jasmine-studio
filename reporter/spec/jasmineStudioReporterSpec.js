const JasmineStudioReporter = require('../jasmineStudioReporter.js');

describe('JasmineStudioReporter', function() {
	const eventNames = ['jasmineDone', 'jasmineStarted', 'specDone',
		'specStarted', 'suiteDone', 'suiteStarted'];

	for (const eventName of eventNames) {
		describe('#' + eventName, function() {
			it('reports the event in one line, with a prefix', function() {
				const log = jasmine.createSpy('console.log');
				const subject = new JasmineStudioReporter(log);
				const payload = {
					foo: {
						bar: [
							'baz',
							'qux',
							'a long string with embedded newlines\na long string with embedded newlines\na long string with embedded newlines\na long string with embedded newlines'
						]
					}
				};

				subject[eventName](payload);

				expect(log).toHaveBeenCalledOnceWith(jasmine.stringMatching(
					/^##jasmineStudio:[^\\n].*$/));
				const msg = log.calls.argsFor(0)[0];
				const json = msg.replace(/^##jasmineStudio:/, '');
				jasmine.debugLog('Extracted JSON: ' + json);
				const parsed = JSON.parse(json);
				expect(parsed).toEqual({ eventName, payload });
			});
		});
	}

	it('does not support parallel mode', function() {
		const subject = new JasmineStudioReporter();
		// Parallel execution would interleave stdout/stderr from different
		// specs, breaking the ability to associate output with specs.
		expect(subject.reporterCapabilities?.parallel).toBeFalsy();
	});
});
