import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "slide"];

  connect() {
    this.isTransitioning = false;
    this.originalSlideCount = this.slideTargets.length;

    // Setup infinite carousel by cloning slides
    this.setupInfiniteCarousel();

    // Start at the first "real" slide (after clones at the beginning)
    this.currentIndex = this.originalSlideCount;
    this.scrollToIndex(this.currentIndex, false);

    // Handle resize for responsive behavior
    this.resizeObserver = new ResizeObserver(() => {
      this.scrollToIndex(this.currentIndex, false);
    });
    this.resizeObserver.observe(this.element);

    // Listen for transition end to handle seamless looping
    this.boundHandleTransitionEnd = this.handleTransitionEnd.bind(this);
    this.trackTarget.addEventListener(
      "transitionend",
      this.boundHandleTransitionEnd,
    );
  }

  disconnect() {
    this.resizeObserver?.disconnect();
    this.trackTarget.removeEventListener(
      "transitionend",
      this.boundHandleTransitionEnd,
    );
  }

  setupInfiniteCarousel() {
    // Clone slides at the end (for forward looping)
    const slides = Array.from(this.slideTargets);
    slides.forEach((slide) => {
      const clone = slide.cloneNode(true);
      clone.setAttribute("aria-hidden", "true");
      clone.removeAttribute("data-carousel-target");
      this.trackTarget.appendChild(clone);
    });

    // Clone slides at the beginning (for backward looping)
    const reversedSlides = [...slides].reverse();
    reversedSlides.forEach((slide) => {
      const clone = slide.cloneNode(true);
      clone.setAttribute("aria-hidden", "true");
      clone.removeAttribute("data-carousel-target");
      this.trackTarget.insertBefore(clone, this.trackTarget.firstChild);
    });

    // Store all slide elements (including clones)
    this.allSlides = Array.from(this.trackTarget.children);
  }

  next() {
    if (this.isTransitioning) return;
    this.isTransitioning = true;
    this.currentIndex++;
    this.scrollToIndex(this.currentIndex, true);
  }

  prev() {
    if (this.isTransitioning) return;
    this.isTransitioning = true;
    this.currentIndex--;
    this.scrollToIndex(this.currentIndex, true);
  }

  scrollToIndex(index, smooth = true) {
    const slideWidth = this.allSlides[0]?.offsetWidth || 0;
    const gap = this.getGapWidth();
    const offset = index * (slideWidth + gap);

    this.trackTarget.style.transition = smooth
      ? "transform 0.7s cubic-bezier(0.25, 0.1, 0.25, 1)"
      : "none";
    this.trackTarget.style.transform = `translateX(-${offset}px)`;

    if (!smooth) {
      this.isTransitioning = false;
    }
  }

  handleTransitionEnd() {
    this.isTransitioning = false;

    const total = this.originalSlideCount;
    const minIndex = total;
    const maxIndex = total * 2 - 1;

    // Seamlessly jump when reaching cloned slides
    if (this.currentIndex > maxIndex) {
      this.currentIndex -= total;
      this.scrollToIndex(this.currentIndex, false);
    } else if (this.currentIndex < minIndex) {
      this.currentIndex += total;
      this.scrollToIndex(this.currentIndex, false);
    }
  }

  getGapWidth() {
    // Match Tailwind gap classes: gap-4 (16px), sm:gap-6 (24px), lg:gap-8 (32px)
    if (window.innerWidth >= 1024) {
      return 32;
    } else if (window.innerWidth >= 640) {
      return 24;
    }
    return 16;
  }

  // Touch/swipe support
  touchStart(event) {
    this.touchStartX = event.touches[0].clientX;
    this.touchStartY = event.touches[0].clientY;
  }

  touchMove(event) {
    if (!this.touchStartX) return;

    const touchEndX = event.touches[0].clientX;
    const touchEndY = event.touches[0].clientY;
    const diffX = this.touchStartX - touchEndX;
    const diffY = this.touchStartY - touchEndY;

    // Only prevent default for horizontal swipes if event is cancelable
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

    const touchEndX = event.changedTouches[0].clientX;
    const diffX = this.touchStartX - touchEndX;

    if (Math.abs(diffX) > 50) {
      if (diffX > 0) {
        this.next();
      } else {
        this.prev();
      }
    }

    this.touchStartX = null;
    this.touchStartY = null;
  }
}
