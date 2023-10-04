import NestedForm from 'stimulus-rails-nested-form';

export default class extends NestedForm {
  static targets = ['nameInput', 'quantityInput'];

  uniqueId = 0;

  connect() {
    super.connect();
  }

  add(t) {
    t.preventDefault();
    const e = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.getUniqueId());
    this.targetTarget.insertAdjacentHTML("beforebegin", e);
  }

  getUniqueId() {
    return `${new Date().getTime()}${this.uniqueId++}`;
  }
}
