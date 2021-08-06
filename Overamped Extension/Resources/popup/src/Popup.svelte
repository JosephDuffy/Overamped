<script lang="ts">
  import type { TabData } from "./TabData"

  export let tabData: TabData
</script>

<div>
  <button id="toggleAllowListButton" />
  <p id="toggleAllowListButtonExplanation">
    If Overamped is disabled for <span class="currentPageDomain" /> it will not
    redirect to the canonical version of
    <span class="currentPageDomain" />.
  </p>
  <p id="openCanonicalLinkExplanation">
    It looks like this page is an AMP page. You may wish to
    <a id="canonicalAnchor" href=""
      >open the canonical version of this website</a
    >.
  </p>
</div>
