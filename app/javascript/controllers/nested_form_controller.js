import NestedForm from "@stimulus-components/rails-nested-form"

export default class extends NestedForm {
  static targets = ["form"]

  add(e) {
    e.preventDefault()

    const counter = this.formTarget.getElementsByClassName('input_field').length + 1
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, counter)
    this.targetTarget.insertAdjacentHTML("beforebegin", content)

    const event = new CustomEvent("rails-nested-form:add", { bubbles: true })
    this.element.dispatchEvent(event)
  }
}
