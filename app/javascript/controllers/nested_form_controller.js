import NestedForm from "@stimulus-components/rails-nested-form"

export default class extends NestedForm {
  getTimestamp() {
    // Return a smaller number instead of timestamp to fit in 4-byte integer
    return Date.now() % 1000000
  }
  connect() {
    super.connect()
    this.updateCounters()
  }

  add(e) {
    super.add(e)
    // Update counters after adding new fields
    setTimeout(() => this.updateCounters(), 10)
  }

  remove(e) {
    super.remove(e)
    // Update counters after removing fields
    setTimeout(() => this.updateCounters(), 10)
  }

  updateCounters() {
    // Update counters for both ingredients and instructions
    const ingredientCounters = this.element.querySelectorAll('.counter .record-counter')
    const instructionCounters = this.element.querySelectorAll('.counter .record-counter')
    
    // Count ingredients
    const ingredientWrappers = this.element.querySelectorAll('.nested-form-wrapper')
    ingredientWrappers.forEach((wrapper, index) => {
      const counter = wrapper.querySelector('.record-counter')
      if (counter) {
        counter.textContent = index + 1
      }
    })

    // Update step numbers for instructions to small sequential numbers
    const instructionWrappers = this.element.querySelectorAll('.nested-form-wrapper')
    instructionWrappers.forEach((wrapper, index) => {
      const stepInput = wrapper.querySelector('input[name*="step"]')
      if (stepInput) {
        stepInput.value = index + 1
      }
      const counter = wrapper.querySelector('.record-counter')
      if (counter) {
        counter.textContent = index + 1
      }
    })
  }
}