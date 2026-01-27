import NestedForm from "@stimulus-components/rails-nested-form"

export default class extends NestedForm {
  // Use base implementation with a custom workaround for ingredient buttons
  
  add(e) {
    // Check if this is an instruction button click
    if (e.target && e.target.textContent && e.target.textContent.includes('ingredient')) {
      console.log('Ingredient button clicked - using custom handler')
      e.preventDefault()
      
      // Manually handle ingredient addition since base may not be working correctly
      this.addIngredient()
    } else if (e.target && e.target.textContent && e.target.textContent.includes('instruction')) {
      console.log('Instruction button clicked - using base method')
      super.add(e)
    } else {
      console.log('Other button clicked - using base method')
      super.add(e)
    }
  }
  
  addIngredient() {
    // Get the form
    const form = this.element.querySelector('form') || this.element.closest('form')
    if (!form) {
      console.error('Could not find form element for ingredient addition')
      return
    }
    
    // Find ingredient templates
    const templates = this.element.querySelectorAll('template')
    const ingredientTemplate = Array.from(templates).find(tmpl => 
      tmpl.innerHTML && tmpl.innerHTML.includes('Ingredient')
    )
    
    if (!ingredientTemplate) {
      console.error('Could not find ingredient template')
      return
    }
    
    // Clone the template
    const content = ingredientTemplate.innerHTML.replace(/NEW_RECORD/g, this.getTimestamp())
    const wrapper = document.createElement('div')
    wrapper.innerHTML = content
    
    // Find the target
    const target = this.element.querySelector('[data-nested-form-target="target"]')
    if (!target) {
      console.error('Could not find target for ingredient addition')
      return
    }
    
    // Insert before target
    target.parentNode.insertBefore(wrapper.firstElementChild, target)
    
    // Dispatch event
    const event = new CustomEvent("rails-nested-form:add", { bubbles: true })
    this.element.dispatchEvent(event)
    
    console.log('Manually added ingredient')
  }
  
  getTimestamp() {
    return new Date().getTime()
  }
}