// Picks the store for the visitor's device. Kept in its own file so it can be unit tested with node.
var AppTimeOutPlatform = (function () {
  var IOS = "https://apps.apple.com/us/app/apptimeout/id6755306490";
  var ANDROID = "https://play.google.com/store/apps/details?id=com.hhdev.apptimeout";

  // Returns the store URL for phones/tablets, or null (desktop/unknown) so the page shows both buttons.
  function destination(userAgent, maxTouchPoints) {
    var ua = userAgent || "";
    if (/android/i.test(ua)) return ANDROID;
    if (/iPhone|iPad|iPod/i.test(ua)) return IOS;
    // iPadOS 13+ reports itself as a Mac but has a touch screen.
    if (/Macintosh/i.test(ua) && maxTouchPoints > 1) return IOS;
    return null;
  }

  return { destination: destination, IOS: IOS, ANDROID: ANDROID };
})();

if (typeof module !== "undefined") module.exports = AppTimeOutPlatform;
