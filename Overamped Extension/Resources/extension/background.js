"use strict";
(() => {
  // background.ts
  browser.runtime.onMessage.addListener(
    (payload, sender, sendResponse) => {
      console.log("Received request", payload, "from", sender, sendResponse);
      payloadHandler(payload).then((response) => {
        console.debug(`Payload handler provided response`, response);
        sendResponse(response);
      }).catch((error) => {
        console.debug(`Payload handler encountered error`, error);
        sendResponse({ error });
      });
      return true;
    }
  );
  async function payloadHandler(payload) {
    if (!objectIsAppPayload(payload)) {
      throw "Invalid payload";
    }
    try {
      switch (payload.request) {
        case "canAccessURL": {
          if (!objectIsCanAccessDomainPayload(payload)) {
            throw "Invalid `canAccessURL` payload";
          }
          const canAccess = await browser.permissions.contains({
            origins: [payload.payload.url]
          });
          console.log(`Can access ${payload.payload.url}: ${canAccess}`);
          return { canAccess };
        }
        default: {
          const response = await browser.runtime.sendNativeMessage(
            "net.yetii.Overamped",
            payload
          );
          console.log("Got response from app", response);
          if (typeof response === "object") {
            return response;
          } else {
            throw "Invalid response from app";
          }
        }
      }
    } catch (error) {
      console.error("Error processing request", error);
      throw error;
    }
  }
  function objectIsAppPayload(object) {
    if (Object.prototype.hasOwnProperty.call(object, "request")) {
      return true;
    } else {
      return false;
    }
  }
  function objectIsCanAccessDomainPayload(object) {
    if (!objectIsAppPayload(object)) {
      return false;
    }
    return Object.prototype.hasOwnProperty.call(object.payload, "url");
  }
})();
