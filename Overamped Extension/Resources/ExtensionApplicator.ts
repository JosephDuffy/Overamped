import NativeAppCommunicator from "./NativeAppCommunicator"

export type ExtensionApplierThunk = (
  ignoredHostnames: string[],
) => Promise<unknown>

export default class ExtensionApplicator {
  #document: Document

  #thunk: ExtensionApplierThunk

  #nativeAppCommunicator: NativeAppCommunicator

  #readyStateChangeListener?: () => void

  #ignoredHostnames?: string[]

  #pendingPromise?: () => void

  #state: "idle" | { pending: () => Promise<unknown> } | "applying"

  constructor(
    document: Document,
    thunk: ExtensionApplierThunk,
    listedForDOMNodeInserted: boolean,
  ) {
    this.#document = document
    this.#thunk = thunk
    this.#state = "idle"
    this.#nativeAppCommunicator = new NativeAppCommunicator()

    this.loadIgnoredHostnames()
    this.migrateIgnoredHostnames()

    if (listedForDOMNodeInserted) {
      // Support "More Results"
      this.#document.addEventListener(
        "DOMNodeInserted",
        this.handleDOMNodeInserted.bind(this),
      )
    }
  }

  public async ignoreHostname(hostname: string): Promise<void> {
    try {
      const ignoredHostnames = await this.#nativeAppCommunicator.ignoreHostname(
        hostname,
      )
      console.log("Hostname has been ignored. New list:", ignoredHostnames)
      this.applyIgnoredHostnames(ignoredHostnames)

      browser.storage.local
        .set({
          cachedIgnoredHostnames: ignoredHostnames,
        })
        .then(() => {
          console.log("New ignored hostnames have been cached")
        })
        .catch((error) => {
          console.error("Failed to cache ignored hostnames", error)
        })
    } catch (error) {
      console.error(`Failed to ignore hostname ${hostname}`, error)
    }
  }

  public async removeIgnoredHostname(hostname: string): Promise<void> {
    try {
      const ignoredHostnames =
        await this.#nativeAppCommunicator.removeIgnoredHostname(hostname)
      console.log(
        "Ignored hostname has been removed. New list:",
        ignoredHostnames,
      )
      this.applyIgnoredHostnames(ignoredHostnames)

      browser.storage.local
        .set({
          cachedIgnoredHostnames: ignoredHostnames,
        })
        .then(() => {
          console.log("New ignored hostnames have been cached")
        })
        .catch((error) => {
          console.error("Failed to cache ignored hostnames", error)
        })
    } catch (error) {
      console.error(`Failed to ignore hostname ${hostname}`, error)
    }
  }

  private applyIgnoredHostnames(ignoredHostnames: string[]) {
    this.#ignoredHostnames = ignoredHostnames

    if (this.#document.readyState === "loading") {
      console.debug(
        "Ignore list has been loaded but the webpage is still loading",
      )

      if (this.#readyStateChangeListener) {
        this.#document.removeEventListener(
          "readystatechange",
          this.#readyStateChangeListener,
        )
      }
      this.#readyStateChangeListener = () => {
        this.applyIgnoredHostnames(ignoredHostnames)
      }
      this.#document.addEventListener(
        "readystatechange",
        this.#readyStateChangeListener,
      )
      return
    }

    this.callThunk(ignoredHostnames)
  }

  private handleDOMNodeInserted() {
    if (this.#document.readyState !== "loading") {
      this.callThunk(this.#ignoredHostnames ?? [])
    }
  }

  private callThunk(ignoredHostnames: string[]) {
    console.debug("Calling thunk with ignored hostnames")

    if (this.#state === "idle") {
      this.#state = "applying"
      this.#thunk(ignoredHostnames).finally(() => {
        this.checkState()
      })
    } else {
      this.#state = {
        pending: () => {
          return this.#thunk(ignoredHostnames)
        },
      }
    }
  }

  private checkState() {
    if (this.#state === "applying") {
      this.#state = "idle"
    } else if (this.#state !== "idle") {
      const pendingPromise = this.#state.pending
      this.#state = "applying"
      pendingPromise().finally(() => {
        this.checkState()
      })
    }
  }

  private loadIgnoredHostnames() {
    this.#nativeAppCommunicator
      .ignoredHostnames()
      .then((ignoredHostnames) => {
        console.debug("Loaded ignored hostnames list", ignoredHostnames)

        this.applyIgnoredHostnames(ignoredHostnames)
      })
      .catch((error) => {
        console.error("Failed to load ignoredHostnames setting", error)
      })

    browser.storage.onChanged.addListener(this.localStorageChanged.bind(this))
  }

  private localStorageChanged(
    changes: browser.storage.ChangeDict,
    areaName: browser.storage.StorageName,
  ) {
    console.debug(`Storage has changed in ${areaName}:`, changes)

    if (areaName !== "local") {
      return
    }

    if ("cachedIgnoredHostnames" in changes) {
      const cachedIgnoredHostnames = changes["cachedIgnoredHostnames"]
      const newIgnoredHostnames = cachedIgnoredHostnames.newValue

      if (newIgnoredHostnames && Array.isArray(newIgnoredHostnames)) {
        this.applyIgnoredHostnames(newIgnoredHostnames)
      }
    }
  }

  private async migrateIgnoredHostnames() {
    try {
      const storage = await browser.storage.local.get("ignoredHostnames")
      const ignoredHostnames = storage["ignoredHostnames"] as
        | string[]
        | undefined

      if (ignoredHostnames !== undefined) {
        await this.#nativeAppCommunicator.migrateIgnoredHostnames(
          ignoredHostnames,
        )
        await browser.storage.local.remove("ignoredHostnames")
      }
    } catch (error) {
      console.error("Failed to load ignored hostnames for migration", error)
    }
  }
}
