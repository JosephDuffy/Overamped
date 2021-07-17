browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log("Received request", request, "from", sender, sendResponse)

  // return new Promise((resolve, reject) => {
  browser.runtime
    .sendNativeMessage("net.yetii.Overamped", {
      request: "ignoredHostnames",
    })
    .then((response) => {
      console.log("Got response", response)
      if (typeof response !== "object") {
        console.error("Response is not an object")
        return
      }

      interface Response {
        ignoredHostnames: string[]
      }

      const ignoredHostnames = (<Response>response)["ignoredHostnames"]
      console.log("Loaded ignoredHostnames", ignoredHostnames)
      sendResponse({ ignoredHostnames: ignoredHostnames })
      // resolve({ ignoredHostnames: ignoredHostnames })
    })
    .catch((error) => {
      console.error("Error messages native app", error)
      // reject(error)
    })
  // })

  // Tell Safari that response will be async
  return true
})
