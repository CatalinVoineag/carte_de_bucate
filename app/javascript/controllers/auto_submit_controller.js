import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce";

export default class extends Controller {
  static targets = ['input']

  connect() {
    this.submit = debounce(this.submit, 200)
    this.inputTarget.addEventListener("input", this.submit);
  }

  submit(event) {
    event.target.parentNode.requestSubmit()
  }
}
