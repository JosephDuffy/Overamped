import {
  type SettingsPayload,
  objectIsSettingsPayload,
  settingsPayloadHasIgnoredHostnamesSetting,
  settingsPayloadHasRedirectOnlySetting,
} from "./SettingsPayload"

export default class NativeAppCommunicator {
  async appSettings(): Promise<{
    ignoredHostnames: string[]
    redirectOnly: boolean
  }> {
    const response = await browser.runtime.sendMessage({
      request: "settings",
      payload: {
        settings: ["redirectOnly", "ignoredHostnames"],
      },
    })
    console.debug("Loaded app settings", response)

    if (!objectIsSettingsPayload(response)) {
      throw "Malformed response to settings request"
    }

    if (!settingsPayloadHasRedirectOnlySetting(response)) {
      throw "Invalid redirect only setting returned"
    }

    if (!settingsPayloadHasIgnoredHostnamesSetting(response)) {
      throw "Invalid ignored hostnames setting returned"
    }

    return {
      ignoredHostnames: response.settings.ignoredHostnames,
      redirectOnly: response.settings.redirectOnly,
    }
  }

  async ignoredHostnames(): Promise<string[]> {
    const response = await browser.runtime.sendMessage({
      request: "settings",
      payload: {
        settings: ["ignoredHostnames"],
      },
    })
    console.debug("Loaded ignoredHostnames settings", response)

    if (!objectIsSettingsPayload(response)) {
      throw "Malformed response to settings request"
    }

    if (
      !Object.prototype.hasOwnProperty.call(
        response.settings,
        "ignoredHostnames",
      ) ||
      !Array.isArray(response.settings.ignoredHostnames)
    ) {
      throw "Invalid ignored hostnames setting returned"
    }

    return response.settings.ignoredHostnames
  }

  /**
   * Adds the provided hostname to ignored hostnames list.
   *
   * @param hostname The hostname to add to the ignored list.
   * @returns The new array of ignored hostnames.
   */
  async ignoreHostname(hostname: string): Promise<string[]> {
    try {
      const response = await browser.runtime.sendMessage({
        request: "ignoreHostname",
        payload: {
          hostname: hostname,
        },
      })

      if (response !== undefined && response["ignoredHostnames"] !== null) {
        console.log(
          "Hostname has been ignored. New list:",
          response["ignoredHostnames"],
        )

        return response["ignoredHostnames"]
      } else {
        const error = new Error(
          "Response to ignoreHostname did not contain ignored hostnames list",
        )
        console.error(error, response)

        throw error
      }
    } catch (error) {
      console.error(`Failed to ignore hostname ${hostname}`, error)
      throw error
    }
  }

  async removeIgnoredHostname(hostname: string): Promise<string[]> {
    try {
      const response = await browser.runtime.sendMessage({
        request: "removeIgnoredHostname",
        payload: {
          hostname: hostname,
        },
      })

      if (response !== undefined && response["ignoredHostnames"] !== null) {
        console.log(
          "Ignored hostname has been removed. New list:",
          response["ignoredHostnames"],
        )

        return response["ignoredHostnames"]
      } else {
        const error = new Error(
          "Response to removeIgnoredHostname did not contain ignored hostnames list",
        )
        console.error(error, response)

        throw error
      }
    } catch (error) {
      console.error(`Failed to remove ignored hostname ${hostname}`, error)
      throw error
    }
  }

  migrateIgnoredHostnames(hostnames: string[]): Promise<void> {
    return new Promise((resolve, reject) => {
      browser.runtime
        .sendMessage({
          request: "migrateIgnoredHostnames",
          payload: {
            ignoredHostnames: hostnames,
          },
        })
        .then(() => {
          console.debug(`Migrated ignored hostnames ${hostnames}`)

          resolve()
        })
        .catch((error) => {
          console.error(
            `Failed to migrate ignored hostnames ${hostnames}`,
            error,
          )
          reject(error)
        })
    })
  }

  async logReplacedLinks(urls: URL[]): Promise<void> {
    if (urls.length === 0) {
      return
    }

    const replacedHostnames = urls.map((url) => url.hostname)
    try {
      await browser.runtime.sendMessage({
        request: "logReplacedLinks",
        payload: {
          replacedLinks: replacedHostnames,
        },
      })
      console.debug(`Logged replaced hostnames ${replacedHostnames}`)
    } catch (error) {
      console.error(
        `Failed to log replaced hostnames ${replacedHostnames}`,
        error,
      )
      throw error
    }
  }

  async logRedirectedLink(
    contentType: "AMP" | "Yandex Turbo" | "Install Checker",
    fromURL: URL,
    toURL: URL,
  ): Promise<void> {
    try {
      await browser.runtime.sendMessage({
        request: "logRedirectedLink",
        payload: {
          contentType,
          fromURL,
          toURL,
        },
      })
      console.debug(`Logged redirection from ${fromURL} to ${toURL}`)
    } catch (error) {
      console.error(
        `Failed to log redirection from ${fromURL} to ${toURL}`,
        error,
      )
      throw error
    }
  }
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace browser.runtime {
    function sendMessage(message: {
      request: "settings"
      payload: {
        settings: ("redirectOnly" | "ignoredHostname")[]
      }
    }): Promise<SettingsPayload>

    function sendMessage(message: {
      request: "ignoredHostnames"
    }): Promise<{ ignoredHostnames: string[] }>

    function sendMessage(message: {
      request: "ignoreHostname"
      payload: {
        hostname: string
      }
    }): Promise<{ ignoredHostnames: string[] }>

    function sendMessage(message: {
      request: "removeIgnoredHostname"
      payload: {
        hostname: string
      }
    }): Promise<{ ignoredHostnames: string[] }>

    function sendMessage(message: {
      request: "migrateIgnoredHostnames"
      payload: {
        ignoredHostnames: string[]
      }
    }): Promise<void>

    function sendMessage(message: {
      request: "logReplacedLinks"
      payload: {
        replacedLinks: string[]
      }
    }): Promise<void>

    function sendMessage(message: {
      request: "canAccessURL"
      payload: {
        url: string
      }
    }): Promise<{ canAccess: boolean }>
  }
}
