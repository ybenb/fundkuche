import { Controller } from '@hotwired/stimulus';
import { Html5QrcodeScanner, Html5QrcodeSupportedFormats } from 'html5-qrcode';

export default class extends Controller {
  static targets = ['scanner', 'audio', 'startBtn'];
  static outlets = ['ingredients'];

  #scanner = null;
  #lastCode = null;

  startScanner(event) {
    event.preventDefault();
    if (this.hasStartBtnTarget) this.startBtnTarget.remove();

    this.#scanner = new Html5QrcodeScanner(
      this.scannerTarget.id,
      {
        fps: 10,
        qrbox: () => {
          const w = Math.min(this.scannerTarget.offsetWidth || 400, 500);
          return { width: w, height: Math.round(w / 2) };
        },
        rememberLastUsedCamera: true,
        aspectRatio: 1.7777778,
        showTorchButtonIfSupported: true,
        formatsToSupport: [
          Html5QrcodeSupportedFormats.EAN_13,
          Html5QrcodeSupportedFormats.EAN_8,
          Html5QrcodeSupportedFormats.UPC_A,
          Html5QrcodeSupportedFormats.UPC_E,
        ],
      },
      false,
    );

    this.#scanner.render(
      (code) => this.#onSuccess(code),
      () => { /* ignore per-frame failures */ },
    );
  }

  #onSuccess(code) {
    if (code === this.#lastCode) return;
    this.#lastCode = code;

    if (this.hasAudioTarget) this.audioTarget.play().catch(() => {});

    // Pause scanner while resolving
    this.#scanner.pause(true);
    this.#showBanner('info', `Barcode erkannt: ${code} – Produkt wird gesucht…`);

    fetch(`/barcodes/resolve?barcode_number=${encodeURIComponent(code)}`, {
      headers: { 'X-CSRF-Token': this.#csrfToken, Accept: 'application/json' },
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.error) throw new Error(data.error);

        this.ingredientsOutlet.add(new Event(''));
        const names = this.ingredientsOutlet.nameInputTargets;
        names[names.length - 1].value = data.product_name;

        this.#showBanner('success', `✓ „${data.product_name}" hinzugefügt`);
      })
      .catch(() => {
        this.#showBanner('danger', `Produkt für Barcode ${code} nicht gefunden.`);
      })
      .finally(() => {
        // Resume scanning after 2.5 s and allow the same code again
        setTimeout(() => {
          this.#lastCode = null;
          try { this.#scanner.resume(); } catch { /* already stopped */ }
        }, 2500);
      });
  }

  disconnect() {
    try { this.#scanner?.clear(); } catch { /* ignore */ }
  }

  #showBanner(type, message) {
    // Remove previous banner
    this.element.querySelector('.barcode-banner')?.remove();

    const banner = document.createElement('div');
    banner.className = `barcode-banner alert alert-${type} alert-dismissible fade show mt-2 mb-0`;
    banner.style.fontSize = '13px';
    banner.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`;
    this.scannerTarget.insertAdjacentElement('afterend', banner);
    setTimeout(() => banner.remove(), 5000);
  }

  get #csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }
}
