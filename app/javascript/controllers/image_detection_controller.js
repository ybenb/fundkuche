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
    });
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }
}
