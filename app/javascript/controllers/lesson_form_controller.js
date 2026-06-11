import { Controller } from "@hotwired/stimulus";

const LESSON_DURATION_MINUTES = 60;

// Keeps the end time in sync with the start time: whenever a start time is
// entered, the end time is set to exactly 60 minutes later.
export default class extends Controller {
  static targets = ["start", "end"];

  syncEnd() {
    const start = this.startTarget.value;
    if (!start) return;

    const [hours, minutes] = start.split(":").map(Number);
    if (Number.isNaN(hours) || Number.isNaN(minutes)) return;

    const total = (hours * 60 + minutes + LESSON_DURATION_MINUTES) % (24 * 60);
    const endHours = String(Math.floor(total / 60)).padStart(2, "0");
    const endMinutes = String(total % 60).padStart(2, "0");

    this.endTarget.value = `${endHours}:${endMinutes}`;
  }
}
