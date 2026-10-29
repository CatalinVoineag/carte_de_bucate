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
    // Only number rows that are still shown; removed rows are hidden but kept for _destroy
    const visibleWrappers = Array.from(this.element.querySelectorAll('.nested-form-wrapper'))
      .filter((wrapper) => wrapper.style.display !== "none")

    visibleWrappers.forEach((wrapper, index) => {
      const counter = wrapper.querySelector('.record-counter')
      if (counter) {
        counter.textContent = index + 1
      }

      const stepInput = wrapper.querySelector('input[name*="[step]"]')
      if (stepInput) {
        stepInput.value = index + 1
      }
    })
  }
}
