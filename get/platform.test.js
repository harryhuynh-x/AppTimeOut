const assert = require('assert');
const P = require('./platform.js');

const iphone = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.2 Mobile/15E148 Safari/604.1';
const ipad = 'Mozilla/5.0 (iPad; CPU OS 17_5 like Mac OS X) AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1';
const ipadAsMac = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15';
const android = 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36';
const samsung = 'Mozilla/5.0 (Linux; Android 13; SAMSUNG SM-S918B) AppleWebKit/537.36 SamsungBrowser/23.0 Chrome/115.0.0.0 Mobile Safari/537.36';
const macDesktop = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15';
const windows = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126.0.0.0 Safari/537.36';
const fbIos = iphone + ' [FBAN/FBIOS;FBAV/450.0]';

assert.strictEqual(P.destination(iphone, 5), P.IOS);
assert.strictEqual(P.destination(ipad, 5), P.IOS);
assert.strictEqual(P.destination(ipadAsMac, 5), P.IOS, 'iPadOS pretending to be a Mac');
assert.strictEqual(P.destination(android, 5), P.ANDROID);
assert.strictEqual(P.destination(samsung, 5), P.ANDROID);
assert.strictEqual(P.destination(fbIos, 5), P.IOS, 'in-app browsers');
assert.strictEqual(P.destination(macDesktop, 0), null, 'real Mac shows both buttons');
assert.strictEqual(P.destination(windows, 0), null);
assert.strictEqual(P.destination('', 0), null);
assert.strictEqual(P.destination(undefined, undefined), null);
console.log('platform detection: all assertions passed');
