import { Controller } from '@hotwired/stimulus';
import { Html5QrcodeScanner, Html5QrcodeSupportedFormats } from 'html5-qrcode';

/* eslint-disable no-console */

export default class extends Controller {
  static targets = ['scanner', 'audio'];
  static outlets = ['ingredients'];

  connect() {
    this.html5QrcodeScanner = new Html5QrcodeScanner(
      this.scannerTarget.id,
      {
        qrbox: { width: 500, height: 500 },
        fps: 5,
        rememberLastUsedCamera: true,
        aspectRatio: 1.7777778,
        showTorchButtonIfSupported: true,
        formatsToSupport: [Html5QrcodeSupportedFormats.EAN_13],
      },
      /* verbose= */
      false,
    );

    this.html5QrcodeScanner.render(
      (decodedText, decodedResult) => {
        this.onScanSuccess(decodedText, decodedResult);
      },
      (_) => {},
    );
  }

  onScanSuccess(decodedText, decodedResult) {
    if (this.lastScannedCode !== decodedText) {
      this.lastScannedCode = decodedText;
      this.audioTarget.play();

      this.addAlert(decodedText);
      this.resolveBarcode(decodedText);
    }
  }

  addAlert(decodedText) {
    const alert = document.createElement('div');
    alert.classList.add('alert', 'alert-success', 'alert-dismissible', 'fade', 'show');
    alert.setAttribute('role', 'alert');
    alert.innerHTML = `<strong>Success!</strong> Scanned code: ${decodedText}. Scan the next product...`;
    const closeButton = document.createElement('button');
    closeButton.classList.add('btn-close');
    closeButton.setAttribute('type', 'button');
    closeButton.setAttribute('data-bs-dismiss', 'alert');
    closeButton.setAttribute('aria-label', 'Close');
    alert.appendChild(closeButton);
    document.querySelector('main').prepend(alert);
  }

  resolveBarcode(decodedText) {
    const params = new URLSearchParams({
      barcode_number: decodedText,
    });

    fetch(`/barcodes/resolve?${params}`, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.csrfToken,
      },
    }).then((res) => res.json()).then((data) => {
      this.ingredientsOutlet.add(new Event(""))
      this.ingredientsOutlet.nameInputTargets[this.ingredientsOutlet.nameInputTargets.length - 1].value = data.product_name;
    });
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }
}
