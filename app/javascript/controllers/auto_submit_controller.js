import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce";

export default class extends Controller {
  static targets = ["input", "secondInput", "form"]

  connect() {
    this.debounceSubmit = debounce(() => this.submit(this.formTarget), 200)
    this.inputTarget.addEventListener("input", this.debounceSubmit);

    if (this.hasSecondInputTarget) {
      this.secondInputTarget.addEventListener("input", this.debounceSubmit);
    }
  }

   disconnect() {
    this.inputTarget.removeEventListener("input", this.debouncedSubmit)
  }

  submit(formTarget) {
    formTarget.requestSubmit()
  }
}
