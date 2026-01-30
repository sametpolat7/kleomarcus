import { Controller } from "@hotwired/stimulus";

/**
 * Gallery Controller - Reusable lightbox for image galleries
 *
 * Usage:
 *   <div data-controller="gallery">
 *     <figure data-gallery-target="item" data-action="click->gallery#open">
 *       <img src="..." alt="...">
 *     </figure>
 *   </div>
 */
export default class extends Controller {
  static targets = ["item"];
  static values = { index: { type: Number, default: 0 } };

  connect() {
    this.createLightbox();
    this.bindKeyboard();
  }

  disconnect() {
    this.lightbox?.remove();
    document.removeEventListener("keydown", this.handleKeydown);
  }

  open(event) {
    this.indexValue = this.itemTargets.indexOf(event.currentTarget);
    this.render();
    this.lightbox.showModal();
  }

  prev() {
    const len = this.itemTargets.length;
    this.indexValue = (this.indexValue - 1 + len) % len;
    this.render();
  }

  next() {
    const len = this.itemTargets.length;
    this.indexValue = (this.indexValue + 1) % len;
    this.render();
  }

  close() {
    this.lightbox.close();
  }

  // Private

  render() {
    const item = this.itemTargets[this.indexValue];
    if (!item) return;

    const img = item.querySelector("img") || item;
    this.image.src = img.src;
    this.image.alt = img.alt || "";
    this.counter.textContent = `${this.indexValue + 1} / ${this.itemTargets.length}`;
  }

  createLightbox() {
    if (this.lightbox && document.body.contains(this.lightbox)) {
      return;
    }

    this.lightbox = document.createElement("dialog");
    this.lightbox.className = "modal";
    this.lightbox.innerHTML = `
      <div class="modal-backdrop bg-black/95" data-action="click->gallery#close"></div>
      <div class="fixed inset-0 flex items-center justify-center pointer-events-none p-4 sm:p-8">
        <img class="max-w-full max-h-full object-contain pointer-events-auto" src="" alt="">
      </div>
      <button class="absolute top-3 right-3 sm:top-4 sm:right-4 w-10 h-10 flex items-center justify-center text-white/70 hover:text-white text-3xl cursor-pointer" aria-label="Kapat">&times;</button>
      <button class="absolute left-2 sm:left-4 top-1/2 -translate-y-1/2 w-10 h-10 flex items-center justify-center text-white/50 hover:text-white text-4xl cursor-pointer" aria-label="Önceki">&#8249;</button>
      <button class="absolute right-2 sm:right-4 top-1/2 -translate-y-1/2 w-10 h-10 flex items-center justify-center text-white/50 hover:text-white text-4xl cursor-pointer" aria-label="Sonraki">&#8250;</button>
      <span class="absolute bottom-4 left-1/2 -translate-x-1/2 text-white/40 text-xs sm:text-sm tabular-nums"></span>
    `;

    this.image = this.lightbox.querySelector("img");
    this.counter = this.lightbox.querySelector("span");

    const buttons = this.lightbox.querySelectorAll("button");
    buttons[0].addEventListener("click", () => this.close());
    buttons[1].addEventListener("click", () => this.prev());
    buttons[2].addEventListener("click", () => this.next());

    document.body.appendChild(this.lightbox);
  }

  bindKeyboard() {
    if (this.handleKeydown) {
      document.removeEventListener("keydown", this.handleKeydown);
    }

    this.handleKeydown = (e) => {
      if (!this.lightbox.open) return;
      if (e.key === "Escape") this.close();
      if (e.key === "ArrowLeft") this.prev();
      if (e.key === "ArrowRight") this.next();
    };
    document.addEventListener("keydown", this.handleKeydown);
  }
}
