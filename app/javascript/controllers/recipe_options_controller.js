import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "detail", "couponZone"]

  connect() {
    // Auto-open first Option-2 recipe if present
    const first = this.rowTargets.find(r => r.dataset.option === "option2")
    if (first) this.#open(first)
  }

  toggle(event) {
    const row = event.currentTarget.closest("[data-recipe-options-target='row']")
    if (!row) return

    const isOpen = row.classList.contains("is-open")
    // Close all rows
    this.rowTargets.forEach(r => this.#close(r))
    if (!isOpen) this.#open(row)
  }

  #open(row) {
    row.classList.add("is-open")
    const detail = row.querySelector(".recipe-detail")
    if (detail) {
      detail.style.maxHeight = detail.scrollHeight + "px"
      detail.style.opacity  = "1"
    }
    const missing = JSON.parse(row.dataset.missing || "[]")
    const option  = row.dataset.option
    this.#renderCoupons(missing, option)
  }

  #close(row) {
    row.classList.remove("is-open")
    const detail = row.querySelector(".recipe-detail")
    if (detail) {
      detail.style.maxHeight = "0"
      detail.style.opacity   = "0"
    }
  }

  #renderCoupons(missing, option) {
    if (!this.hasCouponZoneTarget) return
    const zone = this.couponZoneTarget

    if (missing.length === 0) {
      zone.innerHTML = `<p class="fk-coupon-zone__empty">
        <i class="bi bi-check-circle-fill text-success"></i> Alle Zutaten vorhanden – los geht's!
      </p>`
      return
    }

    const color   = option === "option2" ? "#7faa47" : "#d4892a"
    const label   = option === "option2" ? "Noch fehlt" : "Einkaufsliste"
    const codes   = ["7 610812 11293", "4 006381 33393", "4 260012 52403", "4 710126 03512"]

    zone.innerHTML = `
      <div class="fk-coupon-zone__header">
        <i class="bi bi-ticket-perforated"></i> ${label} – Coop-Coupons
      </div>
      <div class="fk-coupon-zone__grid">
        ${missing.map((ing, i) => `
          <div class="coupon coupon--sm">
            <div class="coupon__left" style="background:${color}">
              <div class="coupon__brand">COOP</div>
              <div class="coupon__amount">10%</div>
              <div class="coupon__amount-label">Rabatt</div>
              <div class="coupon__product">${this.#esc(ing)}</div>
              <div class="coupon__redeem">Einlösbar bei Coop</div>
            </div>
            <div class="coupon__right">
              <div class="coupon__emoji">${this.#emoji(ing)}</div>
              <div class="coupon__barcode"></div>
              <div class="coupon__barcode-num">${codes[i % codes.length]}</div>
              <div class="coupon__validity">Gültig bis 31.05.2026</div>
            </div>
          </div>`).join("")}
      </div>`
  }

  #emoji(name) {
    const map = {
      sahne:"🥛", rahm:"🥛", milch:"🥛", butter:"🧈",
      käse:"🧀", knoblauch:"🧄", zwiebel:"🧅",
      ei:"🥚", eier:"🥚", pasta:"🍝", nudeln:"🍝",
      tomate:"🍅", tomaten:"🍅", salat:"🥗", spinat:"🥬",
      karotte:"🥕", kartoffel:"🥔", zitrone:"🍋", orange:"🍊",
      apfel:"🍎", erdbeere:"🍓", zucker:"🧂", salz:"🧂",
      öl:"🫙", mehl:"🌾", fleisch:"🥩", huhn:"🍗",
      fisch:"🐟", reis:"🍚", linsen:"🫘"
    }
    const key = name.toLowerCase()
    return Object.entries(map).find(([k]) => key.includes(k))?.[1] ?? "🛒"
  }

  #esc(str) {
    return str.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
  }
}
