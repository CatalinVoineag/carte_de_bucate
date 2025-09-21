import NestedForm from "@stimulus-components/rails-nested-form"

export default class extends NestedForm {
  connect() {
    console.log("Do what you want here.")
    super.connect()
  }
}
