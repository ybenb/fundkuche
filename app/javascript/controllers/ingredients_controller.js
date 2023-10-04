import NestedForm from 'stimulus-rails-nested-form';

export default class extends NestedForm {
  static targets = ['nameInput', 'quantityInput'];

  connect() {
    super.connect();
  }
}
