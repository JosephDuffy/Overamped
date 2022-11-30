// Add a listener for messages sent by the extension running in the context of the webpage (via content-script.ts).
browser.runtime.onMessage.addListener(
  (
    // eslint-disable-next-line @typescript-eslint/ban-types
    payload: object,
    sender: browser.runtime.MessageSender,
    // eslint-disable-next-line @typescript-eslint/ban-types
    sendResponse: (response: object) => Promise<void>,
  ): boolean => {
    console.log("Received request", payload, "from", sender, sendResponse)

    // eslint-disable-next-line @typescript-eslint/ban-types
    payloadHandler(payload)
      .then((response) => {
        console.debug(`Payload handler provided response`, response)
        sendResponse(response)
      })
      .catch((error) => {
        console.debug(`Payload handler encountered error`, error)
        sendResponse({ error })
      })

    // Tell Safari that response will be async
    return true
  },
)

/**
 * A function that handles payloads sent by the extension, which runs in the context of the webpage.
 */
async function payloadHandler(
  // eslint-disable-next-line @typescript-eslint/ban-types
  payload: object,
  // eslint-disable-next-line @typescript-eslint/ban-types
): Promise<object> {
  if (!objectIsAppPayload(payload)) {
    throw "Invalid payload"
  }

  try {
    switch (payload.request) {
      case "canAccessURL": {
        if (!objectIsCanAccessDomainPayload(payload)) {
          throw "Invalid `canAccessURL` payload"
        }

        const canAccess = await browser.permissions.contains({
          origins: [payload.payload.url],
        })

        console.log(`Can access ${payload.payload.url}: ${canAccess}`)

        return { canAccess }
      }
      default: {
        const response = await browser.runtime.sendNativeMessage(
          "net.yetii.Overamped",
          payload,
        )

        console.log("Got response from app", response)

        if (typeof response === "object") {
          return response
        } else {
          throw "Invalid response from app"
        }
      }
    }
  } catch (error) {
    console.error("Error processing request", error)
    throw error
  }
}

interface AppPayload {
  readonly request: string
  readonly payload: Record<string, unknown>
}

interface CanAccessDomainPayload extends AppPayload {
  readonly payload: Record<string, unknown> & { url: string }
}

// eslint-disable-next-line @typescript-eslint/ban-types
function objectIsAppPayload(object: object): object is AppPayload {
  if (Object.prototype.hasOwnProperty.call(object, "request")) {
    return true
  } else {
    return false
  }
}

function objectIsCanAccessDomainPayload(
  // eslint-disable-next-line @typescript-eslint/ban-types
  object: object,
): object is CanAccessDomainPayload {
  if (!objectIsAppPayload(object)) {
    return false
  }

  return Object.prototype.hasOwnProperty.call(object.payload, "url")
}
