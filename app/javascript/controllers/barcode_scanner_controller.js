import { Controller } from '@hotwired/stimulus';
import { Html5QrcodeScanner, Html5QrcodeSupportedFormats } from 'html5-qrcode';

/* eslint-disable no-console */

export default class extends Controller {
  static targets = ['scanner', 'audio'];

  connect() {
    this.html5QrcodeScanner = new Html5QrcodeScanner(
      this.element.id,
      {
        qrbox: { width: 500, height: 500 },
        // this.scannerTarget.id,
        fps: 10,
        rememberLastUsedCamera: true,
        aspectRatio:
                    1.7777778,
        showTorchButtonIfSupported:
                    true,
        formatsToSupport:
                    [Html5QrcodeSupportedFormats.EAN_13],
      },
      /* verbose= */
      false,
    );
    this.html5QrcodeScanner.render(
      (decodedText, decodedResult) => {
        this.onScanSuccess(decodedText, decodedResult);
      },
      (error) => {
        this.onScanFailure(error);
      },
    );
    // this.onScanSuccess = this.onScanSuccess.bind(this);
  }

  onScanSuccess(decodedText, decodedResult) {
    console.log(`Code matched = ${decodedText}`, decodedResult);
    if (this.lastScannedCode !== decodedText) {
      this.lastScannedCode = decodedText;
      this.audioTarget.play();

      this.addAlert(decodedText);
      this.html5QrcodeScanner.stop();
      setTimeout(() => {
        this.html5QrcodeScanner.start();
        console.log('scanner re-enabled');
      }, 3000);
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

  onScanFailure(error) {
    // handle scan failure, usually better to ignore and keep scanning.
    // for example:
    console.warn(`Code scan error = ${error}`);
  }
}
