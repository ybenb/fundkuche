import '@hotwired/turbo-rails';
import './controllers';
import * as bootstrap from 'bootstrap';

document.addEventListener('turbo:load', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach((tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl, null));
  document.querySelectorAll('[data-bs-toggle="popover"]')
    .forEach((popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl, null));
});
