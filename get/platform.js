// Picks the store for the visitor's device and carries the campaign source through to it.
// Kept in its own file so it can be unit tested with node.
var AppTimeOutPlatform = (function () {
  var IOS = "https://apps.apple.com/us/app/apptimeout/id6755306490";
  var ANDROID = "https://play.google.com/store/apps/details?id=com.hhdev.apptimeout";

  // Only short, simple tokens are passed on (they end up in a store URL).
  function cleanSource(src) {
    return typeof src === "string" && /^[a-z0-9_-]{1,32}$/i.test(src) ? src : "";
  }

  // Store URLs with the source attached:
  //  - Google Play: `referrer=utm_...` shows up in Play Console acquisition reports.
  //  - App Store: `ct=` campaign token (reported in App Analytics when a campaign link with a
  //    provider token is used; harmless otherwise).
  function iosUrl(src) {
    var s = cleanSource(src);
    return s ? IOS + "?ct=" + encodeURIComponent(s) : IOS;
  }

  function androidUrl(src) {
    var s = cleanSource(src);
    return s ? ANDROID + "&referrer=" + encodeURIComponent("utm_source=" + s + "&utm_medium=smartlink") : ANDROID;
  }

  // Returns the store URL for phones/tablets, or null (desktop/unknown) so the page shows both buttons.
  function destination(userAgent, maxTouchPoints, src) {
    var ua = userAgent || "";
    if (/android/i.test(ua)) return androidUrl(src);
    if (/iPhone|iPad|iPod/i.test(ua)) return iosUrl(src);
    // iPadOS 13+ reports itself as a Mac but has a touch screen.
    if (/Macintosh/i.test(ua) && maxTouchPoints > 1) return iosUrl(src);
    return null;
  }

  return { destination: destination, iosUrl: iosUrl, androidUrl: androidUrl, cleanSource: cleanSource, IOS: IOS, ANDROID: ANDROID };
})();

if (typeof module !== "undefined") module.exports = AppTimeOutPlatform;
