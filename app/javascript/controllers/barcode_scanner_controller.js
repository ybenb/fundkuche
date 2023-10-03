import { Controller } from "@hotwired/stimulus"
import { Html5QrcodeScanner } from "html5-qrcode";

export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!", this.element);

    this.html5QrcodeScanner = new Html5QrcodeScanner(
      this.element.id,
      {fps: 10, qrbox: {width: 150, height: 150},rememberLastUsedCamera: true,
        aspectRatio: 1.7777778,
        showTorchButtonIfSupported: true},
      /* verbose= */ false);
    this.html5QrcodeScanner.render(this.onScanSuccess, this.onScanFailure);
  }

  onScanSuccess(decodedText, decodedResult) {
    // handle the scanned code as you like, for example:
    console.log(`I found a code: ${decodedText}. Fetching the product name...`, decodedResult);
    this.html5QrcodeScanner.stop();
    setTimeout(() => {
      this.html5QrcodeScanner.start();
      console.log('scanner re-enabled');
    }, 3000);
  }

  onScanFailure(error) {
    // handle scan failure, usually better to ignore and keep scanning.
    // for example:
    // console.warn(`Code scan error = ${error}`);
  }
}
