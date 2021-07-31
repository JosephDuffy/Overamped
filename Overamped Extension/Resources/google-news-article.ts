import ExtensionApplicator from "./ExtensionApplicator"
import "./Array+compactMap"
import openURL from "./openURL"

new ExtensionApplicator(document, overrideAMPArticles, false)

function overrideAMPArticles(ignoredHostnames: string[]) {
  const ampArticles = Array.from(
    document.querySelectorAll("article"),
  ).compactMap((article): [HTMLElement, HTMLSpanElement | undefined] => {
    console.debug("Searching article for AMP icon", article)
    console.log(article.querySelectorAll("span"))
    const spans = Array.from(article.querySelectorAll("span"))
    const ampSpanIndex = spans.findIndex((span) => {
      return span.innerText == "amp"
    })

    if (ampSpanIndex === -1) {
      console.debug("Didn't find an AMP icon in", spans)
      return [article, undefined]
    } else {
      return [article, spans[ampSpanIndex]]
    }
  })

  if (ampArticles.length === 0) {
    console.debug("Found no AMP articles")
  }

  ampArticles.forEach((article) => {
    const articleAnchor = article[0].querySelector("a")

    console.log("Found article anchor", articleAnchor)

    if (!articleAnchor) {
      console.debug("Article does not have a link")
      return
    }

    if (article[1]) {
      article[1].style.display = "none"
    }

    articleAnchor.onclick = (event) => {
      console.log("Article anchor clicked", articleAnchor)

      if (openURL(new URL(articleAnchor.href), ignoredHostnames, "push")) {
        event.stopImmediatePropagation()
        event.preventDefault()
        return false
      } else {
        return true
      }
    }
  })
}
