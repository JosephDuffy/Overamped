(() => {
  // background.ts
  browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received request", request, "from", sender, sendResponse);
    browser.runtime.sendNativeMessage("net.yetii.Overamped", {
      request: "ignoredHostnames"
    }).then((response) => {
      console.log("Got response", response);
      if (typeof response !== "object") {
        console.error("Response is not an object");
        return;
      }
      const ignoredHostnames = response["ignoredHostnames"];
      console.log("Loaded ignoredHostnames", ignoredHostnames);
      sendResponse({ ignoredHostnames });
    }).catch((error) => {
      console.error("Error messages native app", error);
    });
    return true;
  });
})();
