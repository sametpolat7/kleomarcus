import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    maxLength: Number,
  };

  connect() {
    this.format();
  }

  format() {
    const digitsBeforeCaret = (
      this.element.value
        .slice(0, this.element.selectionStart || 0)
        .match(/\d/g) || []
    ).length;

    let digits = this.element.value.replace(/\D/g, "");
    // A pasted "+90 5XX ..." arrives as "905XX..." — convert it to the local "05XX..." form.
    if (
      this.hasMaxLengthValue &&
      digits.startsWith("90") &&
      digits.length > this.maxLengthValue
    ) {
      digits = `0${digits.slice(2)}`;
    }
    if (this.hasMaxLengthValue && this.maxLengthValue > 0) {
      digits = digits.slice(0, this.maxLengthValue);
    }

    this.element.value = digits;
    this.element.setSelectionRange(digitsBeforeCaret, digitsBeforeCaret);
  }
}
