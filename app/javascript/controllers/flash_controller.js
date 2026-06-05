import { Controller } from "@hotwired/stimulus";

const AUTO_DISMISS_MS = 3500;

export default class extends Controller {
  static targets = ["bar"];

  connect() {
    this.timer = setTimeout(() => this.dismiss(), AUTO_DISMISS_MS);

    if (this.hasBarTarget) {
      requestAnimationFrame(() => {
        this.barTarget.style.transition = `width ${AUTO_DISMISS_MS}ms linear`;
        this.barTarget.style.width = "0%";
      });
    }
  }

  disconnect() {
    clearTimeout(this.timer);
    clearTimeout(this.removeTimer);
  }

  dismiss() {
    if (this.dismissing) return;
    this.dismissing = true;

    clearTimeout(this.timer);
    this.element.classList.add("opacity-0", "translate-x-2");

    const remove = () => this.element.remove();
    this.element.addEventListener("transitionend", remove, { once: true });
    this.removeTimer = setTimeout(remove, 400);
  }
}
