import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="image-detection"
export default class extends Controller {
  static targets = ['input'];

  static outlets = ['ingredients'];

  upload(event) {
    const file = this.inputTarget.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    this.addAlert('info', `Applying AI on ${file.name}...`);

    fetch('/scanner/upload_image', {
      method: 'POST',
      headers: { 'X-CSRF-Token': this.csrfToken },
      body: formData,
    }).then((res) => res.json()).then((data) => {
      data.ingredients.forEach(({ name, quantity }) => {
        this.ingredientsOutlet.add(new Event(''));
        this.ingredientsOutlet.nameInputTargets[this.ingredientsOutlet.nameInputTargets.length - 1].value = name;
        this.ingredientsOutlet.quantityInputTargets[this.ingredientsOutlet.quantityInputTargets.length - 1].value = quantity;
      });

      this.addAlert('success', 'Fridge scanned successfully!');
    });
  }

  addAlert(type, message) {
    const alert = document.createElement('div');
    alert.classList.add('alert', `alert-${type}`, 'alert-dismissible', 'fade', 'show');
    alert.setAttribute('role', 'alert');
    alert.innerHTML = `<strong>${message}</strong>`;
    const closeButton = document.createElement('button');
    closeButton.classList.add('btn-close');
    closeButton.setAttribute('type', 'button');
    closeButton.setAttribute('data-bs-dismiss', 'alert');
    closeButton.setAttribute('aria-label', 'Close');
    alert.appendChild(closeButton);
    document.querySelector('main').prepend(alert);
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }
}
