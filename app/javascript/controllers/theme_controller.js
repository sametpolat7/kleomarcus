import { Controller } from "@hotwired/stimulus";

export default class ThemeController extends Controller {
  static values = {
    lightTheme: { type: String, default: "pastel" },
    darkTheme: { type: String, default: "dracula" },
  };

  connect() {
    this.applyInitialTheme();
  }

  applyInitialTheme() {
    const storedTheme = localStorage.getItem("theme") || this.lightThemeValue;
    this.setTheme(storedTheme);
  }

  toggleTheme(event) {
    const selectedTheme = event.currentTarget.checked
      ? this.darkThemeValue
      : this.lightThemeValue;

    this.setTheme(selectedTheme);
    localStorage.setItem("theme", selectedTheme);
  }

  setTheme(themeName) {
    document.documentElement.dataset.theme = themeName;

    const toggleCheckbox = this.element.querySelector('input[type="checkbox"]');
    if (toggleCheckbox) {
      toggleCheckbox.checked = themeName === this.darkThemeValue;
    }
  }
}
