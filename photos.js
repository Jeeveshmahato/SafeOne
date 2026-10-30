// Shows the photos taken after an SOS (lib/services/sos_photo_link.dart).
// The id comes after the # in the link, which browsers never send to any
// server, so it stays out of every log; the photos are read straight from
// the database over its REST API, which allows reading one SOS by its exact
// id and nothing else (firebase/firestore.rules).
(function () {
  "use strict";

  var PROJECT = "safeone-d96a1";
  var MAX_PHOTOS = 2;
  // While the photos aren't there yet (the phone may still be offline):
  // look again every 30 seconds, for half an hour.
  var RECHECK_MS = 30000;
  var RECHECK_FOR_MS = 30 * 60000;

  var statusEl = document.getElementById("status");
  var photosEl = document.getElementById("photos");
  var retryWrap = document.getElementById("retry-wrap");
  var urls = [];
  var recheckTimer = null;
  var waitingSince = null;

  // Testing on this computer against the Firebase emulator:
  // http://localhost:8000/photos.html?emulator#<id>
  var local = /^(localhost|127\.0\.0\.1)$/.test(location.hostname) &&
    /[?&]emulator\b/.test(location.search);
  var base = local
    ? "http://127.0.0.1:8080/v1/projects/demo-safeone/databases/(default)/documents/sos_photos/"
    : "https://firestore.googleapis.com/v1/projects/" + PROJECT + "/databases/(default)/documents/sos_photos/";

  function say(text) {
    statusEl.textContent = text;
  }

  function clear() {
    clearTimeout(recheckTimer);
    urls.forEach(function (u) { URL.revokeObjectURL(u); });
    urls = [];
    photosEl.textContent = "";
    retryWrap.hidden = true;
  }

  function when(iso) {
    var d = new Date(iso);
    if (isNaN(d)) return "";
    return d.toLocaleString(undefined, {
      weekday: "short", day: "numeric", month: "short",
      hour: "numeric", minute: "2-digit"
    });
  }

  // GET one document: its fields, null if it isn't there (or no longer
  // may be read), or throws when the network fails.
  function getDoc(path) {
    return fetch(base + path, { cache: "no-store", credentials: "omit", referrerPolicy: "no-referrer" })
      .then(function (r) {
        if (r.status === 403 || r.status === 404) return null;
        if (!r.ok) throw new Error("HTTP " + r.status);
        return r.json().then(function (d) { return d.fields || {}; });
      });
  }

  function bytesToBlobUrl(b64) {
    var bin = atob(b64.replace(/-/g, "+").replace(/_/g, "/"));
    var bytes = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    var url = URL.createObjectURL(new Blob([bytes], { type: "image/webp" }));
    urls.push(url);
    return url;
  }

  function showPhoto(i, url) {
    var fig = document.createElement("figure");
    var img = document.createElement("img");
    img.alt = "SOS photo " + (i + 1);
    img.src = url;
    img.onerror = function () {
      say("This browser can't show these photos. Open the link in Chrome, " +
        "or save them below and open them on another device.");
    };
    var cap = document.createElement("figcaption");
    var save = document.createElement("a");
    save.href = url;
    save.download = "sos-photo-" + (i + 1) + ".webp";
    save.textContent = "Save photo " + (i + 1);
    cap.appendChild(save);
    fig.appendChild(img);
    fig.appendChild(cap);
    photosEl.appendChild(fig);
  }

  function notThereYet() {
    if (waitingSince === null) waitingSince = Date.now();
    if (Date.now() - waitingSince < RECHECK_FOR_MS) {
      say("The photos aren't here yet. If their phone has no internet, they " +
        "appear once it's back online, and this page keeps checking. Links " +
        "also stop working 7 days after the photos were taken.");
      recheckTimer = setTimeout(load, RECHECK_MS);
    } else {
      say("These photos aren't available. Their phone may not have had " +
        "internet yet, or the link has expired (after 7 days).");
      retryWrap.hidden = false;
    }
  }

  function load() {
    clear();
    var id = location.hash.replace(/^#/, "");
    if (!/^[A-Za-z0-9]{22}$/.test(id)) {
      say("This link isn't complete. Copy the whole link from the text message.");
      return;
    }
    say("Loading the photos…");
    getDoc(id).then(function (sos) {
      if (!sos) return notThereYet();
      var count = Math.min(parseInt((sos.count || {}).integerValue, 10) || 0, MAX_PHOTOS);
      var taken = (sos.taken || {}).timestampValue;
      var expires = (sos.expireAt || {}).timestampValue;
      var reads = [];
      for (var i = 0; i < count; i++) reads.push(getDoc(id + "/photos/" + i));
      return Promise.all(reads).then(function (photos) {
        var shown = 0;
        photos.forEach(function (p, i) {
          var b64 = p && p.image && p.image.bytesValue;
          if (b64) {
            showPhoto(i, bytesToBlobUrl(b64));
            shown++;
          }
        });
        if (!shown) return notThereYet();
        waitingSince = null;
        say((taken ? "Taken " + when(taken) + ". " : "") +
          (expires ? "This link stops working " + when(expires) + "." : ""));
      });
    }).catch(function () {
      say("Couldn't load the photos. Check your internet connection and try again.");
      retryWrap.hidden = false;
    });
  }

  document.getElementById("retry").addEventListener("click", function () {
    waitingSince = null;
    load();
  });
  window.addEventListener("hashchange", function () {
    waitingSince = null;
    load();
  });
  load();
})();
