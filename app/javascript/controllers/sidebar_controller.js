import { Controller } from "@hotwired/stimulus";

const STORAGE_KEY = "admin-sidebar-collapsed";

export default class extends Controller {
  connect() {
    if (localStorage.getItem(STORAGE_KEY) === "true") {
      this.element.dataset.collapsed = "true";
    }
  }

  toggle() {
    const next = this.element.dataset.collapsed !== "true";
    this.element.dataset.collapsed = next ? "true" : "false";
    localStorage.setItem(STORAGE_KEY, next ? "true" : "false");
  }

  brand(event) {
    if (this.element.dataset.collapsed === "true") {
      event.preventDefault();
      this.toggle();
    }
  }
}
