import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "slide"];
  static DURATION = 150;
  static EASING = "cubic-bezier(0.4, 0, 0.2, 1)";

  connect() {
    this.isTransitioning = false; // Prevents double-click navigation

    // Recalculate positions on window resize
    this.resizeObserver = new ResizeObserver(() => this.resetPosition());
    this.resizeObserver.observe(this.element);
  }

  disconnect() {
    this.resizeObserver?.disconnect();
  }

  next() {
    if (this.isTransitioning) return;
    this.isTransitioning = true;

    const offset = this.getSlideOffset();
    this.animateTrack(`translateX(-${offset}px)`); // Slide left

    setTimeout(() => {
      this.trackTarget.appendChild(this.slideTargets[0]); // Move first card to end
      this.resetPosition(); // Jump back to zero
      this.isTransitioning = false;
    }, this.constructor.DURATION);
  }

  prev() {
    if (this.isTransitioning) return;
    this.isTransitioning = true;

    const lastSlide = this.slideTargets[this.slideTargets.length - 1];
    this.trackTarget.insertBefore(lastSlide, this.trackTarget.firstChild); // Move last card to beginning

    const offset = this.getSlideOffset();
    this.trackTarget.style.transition = "none";
    this.trackTarget.style.transform = `translateX(-${offset}px)`;

    void this.trackTarget.offsetHeight;
    this.animateTrack("translateX(0)");

    setTimeout(() => {
      this.isTransitioning = false;
    }, this.constructor.DURATION);
  }

  animateTrack(transform) {
    this.trackTarget.style.transition = `transform ${this.constructor.DURATION}ms ${this.constructor.EASING}`;
    this.trackTarget.style.transform = transform;
  }

  resetPosition() {
    this.trackTarget.style.transition = "none";
    this.trackTarget.style.transform = "translateX(0)";
  }

  getSlideOffset() {
    const slideWidth = this.slideTargets[0]?.offsetWidth || 0;
    const gap = this.getGapWidth();
    return slideWidth + gap; // Total distance to slide
  }

  getGapWidth() {
    // Match Tailwind gap classes: gap-4 (16px), sm:gap-6 (24px), lg:gap-8 (32px)
    if (window.innerWidth >= 1024) return 32;
    if (window.innerWidth >= 640) return 24;
    return 16;
  }

  // Touch/swipe support
  touchStart(event) {
    this.touchStartX = event.touches[0].clientX;
    this.touchStartY = event.touches[0].clientY;
  }

  touchMove(event) {
    if (!this.touchStartX) return;

    const diffX = this.touchStartX - event.touches[0].clientX;
    const diffY = this.touchStartY - event.touches[0].clientY;

    if (
      Math.abs(diffX) > Math.abs(diffY) &&
      Math.abs(diffX) > 50 &&
      event.cancelable
    ) {
      event.preventDefault();
    }
  }

  touchEnd(event) {
    if (!this.touchStartX) return;

    const diffX = this.touchStartX - event.changedTouches[0].clientX;

    if (Math.abs(diffX) > 50) {
      diffX > 0 ? this.next() : this.prev();
    }

    this.touchStartX = null;
    this.touchStartY = null;
  }
}
