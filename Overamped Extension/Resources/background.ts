browser.runtime.onMessage.addListener(
  (
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    payload: any,
    sender: browser.runtime.MessageSender,
    // eslint-disable-next-line @typescript-eslint/ban-types
    sendResponse: (response: object) => Promise<void>,
  ): boolean => {
    console.log("Received request", payload, "from", sender, sendResponse)

    browser.runtime
      .sendNativeMessage("net.yetii.Overamped", payload)
      .then((response) => {
        console.log("Got response from app", response)

        if (typeof response === "object") {
          sendResponse(response)
        } else {
          sendResponse({})
        }
      })
      .catch((error) => {
        console.error("Error messages native app", error)
        sendResponse({ error: error })
      })

    // Tell Safari that response will be async
    return true
  },
)
