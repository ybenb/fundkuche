import { Controller } from '@hotwired/stimulus';

const isMobile = () => /Mobi|Android|iPhone|iPad/i.test(navigator.userAgent);

export default class extends Controller {
  static targets = ['cameraInput', 'galleryInput', 'modal', 'video', 'canvas'];
  static outlets = ['ingredients'];

  #stream = null;

  // ── Camera ───────────────────────────────────────────────────────────────

  async openCamera() {
    if (isMobile()) {
      // Mobile: native camera via file input with capture attribute
      this.cameraInputTarget.value = '';
      this.cameraInputTarget.click();
      return;
    }

    // Desktop: getUserMedia → show live preview modal
    try {
      this.#stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment', width: { ideal: 1280 } },
      });
      this.videoTarget.srcObject = this.#stream;
      this.modalTarget.style.display = 'flex';
    } catch {
      // Fallback: open file picker so user can at least choose a photo
      this.cameraInputTarget.value = '';
      this.cameraInputTarget.click();
    }
  }

  capture() {
    const video  = this.videoTarget;
    const canvas = this.canvasTarget;
    canvas.width  = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);
    this.closeCamera();
    canvas.toBlob(
      (blob) => this.#sendFile(new File([blob], 'camera.jpg', { type: 'image/jpeg' })),
      'image/jpeg', 0.92
    );
  }

  closeCamera() {
    this.modalTarget.style.display = 'none';
    if (this.#stream) {
      this.#stream.getTracks().forEach((t) => t.stop());
      this.#stream = null;
    }
  }

  uploadFromCamera(event) {
    const file = event.target.files[0];
    if (!file) return;
    event.target.value = '';
    this.#sendFile(file);
  }

  disconnect() { this.closeCamera(); }

  // ── Gallery ──────────────────────────────────────────────────────────────

  openGallery() {
    this.galleryInputTarget.value = '';
    this.galleryInputTarget.click();
  }

  uploadFromGallery(event) {
    const file = event.target.files[0];
    if (!file) return;
    event.target.value = '';
    this.#sendFile(file);
  }

  // ── Shared upload logic ───────────────────────────────────────────────────

  #sendFile(file) {
    const formData = new FormData();
    formData.append('file', file);
    this.setLoading(true);

    fetch('/scanner/upload_image', {
      method: 'POST',
      headers: { 'X-CSRF-Token': this.csrfToken },
      body: formData,
    })
      .then((res) => res.json())
      .then((data) => {
        if (data.error) throw new Error(data.error);
        data.ingredients.forEach(({ name, quantity }) => {
          this.ingredientsOutlet.add(new Event(''));
          const names      = this.ingredientsOutlet.nameInputTargets;
          const quantities = this.ingredientsOutlet.quantityInputTargets;
          names[names.length - 1].value      = name;
          quantities[quantities.length - 1].value = quantity;
        });
        this.showBanner('success', `✓ ${data.ingredients.length} Zutaten erkannt`);
      })
      .catch((err) => {
        this.showBanner('danger', err.message || 'KI-Erkennung fehlgeschlagen. Bitte versuche es erneut.');
      })
      .finally(() => this.setLoading(false));
  }

  setLoading(on) {
    this.element.querySelectorAll('button').forEach((b) => {
      b.style.opacity      = on ? '0.6' : '1';
      b.style.pointerEvents = on ? 'none' : '';
    });
    let spinner = this.element.querySelector('.ai-spinner');
    if (on && !spinner) {
      spinner = document.createElement('div');
      spinner.className = 'ai-spinner d-flex align-items-center gap-2 mt-2';
      spinner.style.cssText = 'font-size:13px;color:var(--fooby-muted,#888)';
      spinner.innerHTML = '<div class="spinner-border spinner-border-sm" role="status"></div> KI analysiert Foto…';
      this.element.appendChild(spinner);
    } else if (!on && spinner) {
      spinner.remove();
    }
  }

  showBanner(type, message) {
    const banner = document.createElement('div');
    banner.className = `alert alert-${type} alert-dismissible fade show mt-2 mb-0`;
    banner.style.fontSize = '13px';
    banner.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`;
    this.element.appendChild(banner);
    setTimeout(() => banner.remove(), 5000);
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }
}
