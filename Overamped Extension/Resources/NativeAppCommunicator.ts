export default class NativeAppCommunicator {
  ignoredHostnames(): Promise<string[]> {
    return new Promise((resolve, reject) => {
      browser.runtime
        .sendMessage({
          request: "ignoredHostnames",
        })
        .then((response) => {
          console.debug("Loaded ignored hostnames list", response)

          if (response !== undefined && response["ignoredHostnames"] !== null) {
            resolve(response["ignoredHostnames"])
          } else {
            resolve([])
          }
        })
        .catch((error) => {
          console.error("Failed to load ignoredHostnames setting", error)
          reject(error)
        })
    })
  }

  ignoreHostname(hostname: string): Promise<void> {
    return new Promise((resolve, reject) => {
      browser.runtime
        .sendMessage({
          request: "ignoreHostname",
          payload: {
            hostname: hostname,
          },
        })
        .then(() => {
          console.debug(`Ignored hostname ${hostname}`)

          resolve()
        })
        .catch((error) => {
          console.error(`Failed to ignore hostname ${hostname}`, error)
          reject(error)
        })
    })
  }

  removeIgnoredHostname(hostname: string): Promise<void> {
    return new Promise((resolve, reject) => {
      browser.runtime
        .sendMessage({
          request: "removeIgnoredHostname",
          payload: {
            hostname: hostname,
          },
        })
        .then(() => {
          console.debug(`Removed ignored hostname ${hostname}`)

          resolve()
        })
        .catch((error) => {
          console.error(`Failed to remove ignored hostname ${hostname}`, error)
          reject(error)
        })
    })
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
}

// eslint-disable-next-line @typescript-eslint/no-namespace
declare namespace browser.runtime {
  export function sendMessage(message: {
    request: "ignoredHostnames"
  }): Promise<{ ignoredHostnames: string[] }>

  export function sendMessage(message: {
    request: "ignoreHostname"
    payload: {
      hostname: string
    }
  }): Promise<void>

  export function sendMessage(message: {
    request: "removeIgnoredHostname"
    payload: {
      hostname: string
    }
  }): Promise<void>

  export function sendMessage(message: {
    request: "migrateIgnoredHostnames"
    payload: {
      ignoredHostnames: string[]
    }
  }): Promise<void>
}
