import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    this._timer = null
  }

  search() {
    clearTimeout(this._timer)
    this._timer = setTimeout(() => this.formTarget.requestSubmit(), 400)
  }
}
