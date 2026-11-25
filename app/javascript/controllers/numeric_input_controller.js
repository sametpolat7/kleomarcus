import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    maxLength: Number,
    countryCode: { type: String, default: "" },
    delimiter: { type: String, default: "" },
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

    if (
      this.countryCodeValue &&
      digits.startsWith(this.countryCodeValue) &&
      digits.length > this.maxLengthValue
    ) {
      digits = `0${digits.slice(this.countryCodeValue.length)}`;
    }
    if (this.hasMaxLengthValue && this.maxLengthValue > 0) {
      digits = digits.slice(0, this.maxLengthValue);
    }

    this.element.value = this.delimiterValue
      ? digits.replace(/\B(?=(\d{3})+(?!\d))/g, this.delimiterValue)
      : digits;

    const caret = this.caretAfterDigits(digitsBeforeCaret);
    this.element.setSelectionRange(caret, caret);
  }

  // Index just past the nth digit, so delimiters inserted while typing do not move the caret.
  caretAfterDigits(count) {
    if (count === 0) return 0;

    let seen = 0;
    for (let index = 0; index < this.element.value.length; index++) {
      if (/\d/.test(this.element.value[index]) && ++seen === count) return index + 1;
    }
    return this.element.value.length;
  }
}
