import ExtensionApplier from "./ExtensionApplier"
import "./Array+compactMap"

new ExtensionApplier(document, overrideAMPArticles)

function overrideAMPArticles() {
  const ampArticles = Array.from(
    document.querySelectorAll("article"),
  ).compactMap((article): [HTMLElement, HTMLSpanElement] | null => {
    console.debug("Searching article for AMP icon", article)
    console.log(article.querySelectorAll("span"))
    const spans = Array.from(article.querySelectorAll("span"))
    const ampSpanIndex = spans.findIndex((span) => {
      return span.innerText == "amp"
    })

    if (ampSpanIndex === -1) {
      console.debug("Didn't find an AMP icon in", spans)
      return null
    } else {
      return [article, spans[ampSpanIndex]]
    }
  })

  if (ampArticles.length === 0) {
    console.debug("Found no AMP articles")
  }

  ampArticles.forEach((article) => {
    const articleAnchor = article[0].querySelector("a")

    console.log("Found AMP article anchor", articleAnchor)

    if (!articleAnchor) {
      console.debug("Article does not have a link")
      return
    }

    article[1].style.display = "none"

    articleAnchor.onclick = (event) => {
      console.log("Article anchor clicked", articleAnchor)
      event.preventDefault()

      window.location.assign(articleAnchor.href)

      return false
    }
  })
}
