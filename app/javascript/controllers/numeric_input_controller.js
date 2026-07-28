import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    maxLength: Number,
    countryCode: { type: String, default: "" },
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

    this.element.value = digits;
    this.element.setSelectionRange(digitsBeforeCaret, digitsBeforeCaret);
  }
}
