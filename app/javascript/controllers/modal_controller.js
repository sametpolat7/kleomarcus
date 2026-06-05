import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dialog", "frame"];

  connect() {
    this.dialogEl = this.hasDialogTarget ? this.dialogTarget : this.element;

    this.boundFrameLoad = this.handleFrameLoad.bind(this);
    this.boundBackdropClick = this.handleBackdropClick.bind(this);
    this.boundClose = this.handleClose.bind(this);

    if (this.hasFrameTarget) {
      this.frameTarget.addEventListener("turbo:frame-load", this.boundFrameLoad);
    }
    this.dialogEl.addEventListener("click", this.boundBackdropClick);
    this.dialogEl.addEventListener("close", this.boundClose);
  }

  disconnect() {
    if (this.hasFrameTarget) {
      this.frameTarget.removeEventListener("turbo:frame-load", this.boundFrameLoad);
    }
    this.dialogEl.removeEventListener("click", this.boundBackdropClick);
    this.dialogEl.removeEventListener("close", this.boundClose);
  }

  open() {
    if (!this.dialogEl.open) this.dialogEl.showModal();
  }

  close(event) {
    event?.preventDefault();
    if (this.dialogEl.open) this.dialogEl.close();
  }

  handleFrameLoad() {
    const hasContent = this.frameTarget.innerHTML.trim().length > 0;
    if (hasContent) {
      this.open();
    } else if (this.dialogEl.open) {
      this.close();
      window.Turbo?.visit(window.location.href, { action: "replace" });
    }
  }

  handleBackdropClick(event) {
    if (event.target === this.dialogEl) this.close();
  }

  handleClose() {
    if (this.hasFrameTarget) {
      this.frameTarget.innerHTML = "";
      this.frameTarget.removeAttribute("src");
    }
  }
}
