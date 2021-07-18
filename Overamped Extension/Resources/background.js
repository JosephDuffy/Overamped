(() => {
  // background.ts
  browser.runtime.onMessage.addListener((payload, sender, sendResponse) => {
    console.log("Received request", payload, "from", sender, sendResponse);
    browser.runtime.sendNativeMessage("net.yetii.Overamped", payload).then((response) => {
      console.log("Got response from app", response);
      if (typeof response === "object") {
        sendResponse(response);
      } else {
        sendResponse({});
      }
    }).catch((error) => {
      console.error("Error messages native app", error);
      sendResponse({ error });
    });
    return true;
  });
})();
