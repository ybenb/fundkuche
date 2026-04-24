import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "empty", "count"]

  connect() {
    this._observer = new MutationObserver(() => this.update())
    // Watch the entire form area for any input changes or DOM mutations
    const form = document.querySelector('[data-controller~="ingredients"]')
    if (form) {
      this._observer.observe(form, { childList: true, subtree: true, characterData: true })
    }
    // Also listen for input events bubbling up from ingredient fields
    document.addEventListener("input", this._onInput = () => this.update())
    this.update()
  }

  disconnect() {
    this._observer?.disconnect()
    document.removeEventListener("input", this._onInput)
  }

  update() {
    const inputs = document.querySelectorAll('[data-ingredients-target="nameInput"]')
    const items = Array.from(inputs)
      .map(i => i.value.trim())
      .filter(v => v.length > 0)

    if (this.hasCountTarget) this.countTarget.textContent = items.length

    if (items.length === 0) {
      this.emptyTarget.style.display = "flex"
      this.listTarget.innerHTML = ""
      return
    }

    this.emptyTarget.style.display = "none"
    this.listTarget.innerHTML = items.map((name, i) =>
      `<div class="fridge-item" style="animation-delay:${i * 40}ms">
        <i class="bi bi-check-circle-fill"></i>
        <span>${this.#escape(name)}</span>
      </div>`
    ).join("")
  }

  #escape(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}
