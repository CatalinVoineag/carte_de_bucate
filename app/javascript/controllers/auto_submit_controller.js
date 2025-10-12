import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce";

export default class extends Controller {
  static targets = ["receipeInput", "tagsInput", "ingredientInput", "form"]

  connect() {
    this.debounceSubmit = debounce(() => this.submit(this.formTarget), 200)
    this.receipeInputTarget.addEventListener("input", this.debounceSubmit);
    this.tagsInputTarget.addEventListener("click", this.debounceSubmit);
    this.ingredientInputTarget.addEventListener("input", this.debounceSubmit);
  }

   disconnect() {
    this.receipeInputTarget.removeEventListener("input", this.debounceSubmit);
    this.tagsInputTarget.removeEventListener("click", this.debounceSubmit);
    this.ingredientInputTarget.removeEventListener("input", this.debounceSubmit);
  }

  submit(formTarget) {
    formTarget.requestSubmit()
  }
}
