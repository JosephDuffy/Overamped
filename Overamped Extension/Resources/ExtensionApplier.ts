export type ExtensionApplierThunk = (ignoredHostnames: string[]) => void

export default class ExtensionApplier {
  #document: HTMLDocument

  #thunk: ExtensionApplierThunk

  #readyStateChangeListener?: () => void

  #ignoredHostnames?: string[]

  constructor(document: HTMLDocument, thunk: ExtensionApplierThunk) {
    this.#document = document
    this.#thunk = thunk

    this.loadIgnoredHostnames()
  }

  private applyIgnoredHostnames(ignoredHostnames: string[]) {
    this.#ignoredHostnames = ignoredHostnames

    if (this.#document.readyState == "loading") {
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

    this.#document.removeEventListener(
      "DOMNodeInserted",
      this.handleDOMNodeInserted.bind(this),
    )

    // Support "More Results"
    this.#document.addEventListener(
      "DOMNodeInserted",
      this.handleDOMNodeInserted.bind(this),
    )

    this.#thunk(ignoredHostnames)
  }

  private handleDOMNodeInserted() {
    this.#thunk(this.#ignoredHostnames ?? [])
  }

  private loadIgnoredHostnames() {
    browser.storage.local
      .get("ignoredHostnames")
      .then((storage) => {
        const ignoredHostnames =
          (storage["ignoredHostnames"] as string[] | undefined) ?? []

        console.debug("Loaded ignored hostnames list", ignoredHostnames)

        this.applyIgnoredHostnames(ignoredHostnames)
      })
      .catch((error) => {
        console.error("Failed to load ignoredHostnames setting", error)
      })

    browser.storage.onChanged.addListener((changes) => {
      if (changes["ignoredHostnames"] && changes["ignoredHostnames"].newValue) {
        console.debug(
          "Ignored hostnames setting changed",
          changes["ignoredHostnames"],
        )
        const ignoredHostnames = changes["ignoredHostnames"].newValue

        this.applyIgnoredHostnames(ignoredHostnames)
      }
    })
  }
}
