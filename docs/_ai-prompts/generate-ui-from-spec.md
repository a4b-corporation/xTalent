# Generate UI Code from Specifications

## Purpose
This prompt helps AI generate working UI code (HTML + HTMX + Shoelace) from UI specifications and API specs.

## Context
You are a frontend developer creating user interfaces for an HCM system using HTMX and Shoelace Web Components. You will be given UI specifications and API specifications, and you need to generate working HTML code.

---

## Prompt Template

```
You are a frontend developer creating UI for the xTalent HCM system.

Technology Stack:
- **HTMX**: For dynamic interactions without JavaScript
- **Shoelace**: Web components for UI elements
- **Vanilla CSS**: For custom styling

I will provide you with:
1. UI Specification (MD) - defining layout, components, states, interactions
2. API Specification (YAML) - defining endpoints and data structures

Your task is to generate a complete, working HTML page that includes:

1. **HTML Structure**
   - Semantic HTML5
   - Proper document structure
   - Accessibility attributes (ARIA labels, roles)

2. **Shoelace Components**
   - Use appropriate Shoelace components (sl-input, sl-select, sl-button, etc.)
   - Configure components according to UI spec
   - Include validation attributes

3. **HTMX Attributes**
   - Use hx-get, hx-post, hx-put, hx-delete for API calls
   - Use hx-target for updating specific elements
   - Use hx-swap for controlling how content is swapped
   - Use hx-trigger for event handling
   - Use hx-indicator for loading states

4. **Form Handling**
   - Client-side validation using HTML5 and Shoelace
   - Error display for field-level and form-level errors
   - Loading states during API calls
   - Success/error notifications

5. **Styling**
   - Use Shoelace CSS variables for theming
   - Add custom CSS for layout and spacing
   - Ensure responsive design
   - Follow xTalent design system

6. **Data Binding**
   - Populate dropdowns from API endpoints
   - Display computed values
   - Handle dynamic field visibility

Guidelines:
- Write clean, semantic HTML
- Use Shoelace components for all UI elements
- Use HTMX for all server interactions (no custom JavaScript)
- Include proper error handling
- Make it accessible (WCAG 2.1 AA)
- Add comments explaining complex interactions
- Include loading states and feedback
- Make it responsive

Here are the input files:

[PASTE UI SPEC]

[PASTE API SPEC (relevant endpoints)]

Please generate the complete HTML file with embedded CSS.
```

---

## Example Usage

### Input

**UI Spec** (excerpt):
```markdown
## Screen: Leave Request Form

### Components:
1. Leave Type Selector (Dropdown)
   - Required
   - Load from: GET /api/leave-types
   - Display: "{name} ({maxDaysPerYear} days/year)"

2. Start Date (Date Picker)
   - Required
   - Min: today
   - Validation: Cannot be in past

3. End Date (Date Picker)
   - Required
   - Min: startDate
   - Validation: Must be >= startDate

4. Total Days (Readonly)
   - Computed from startDate and endDate

5. Reason (Textarea)
   - Optional
   - Max 500 characters

### Interactions:
- On submit: POST /api/leave-requests
- On success: Show toast, redirect to list
- On error: Show error message
```

**API Spec** (excerpt):
```yaml
paths:
  /leave-requests:
    post:
      requestBody:
        content:
          application/json:
            schema:
              properties:
                leaveTypeId: { type: string, format: uuid }
                startDate: { type: string, format: date }
                endDate: { type: string, format: date }
                reason: { type: string, maxLength: 500 }
```

### Expected Output

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Leave Request - xTalent</title>
  
  <!-- Shoelace -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/themes/light.css" />
  <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/shoelace-autoloader.js"></script>
  
  <!-- HTMX -->
  <script src="https://unpkg.com/htmx.org@1.9.10"></script>
  
  <style>
    body {
      font-family: var(--sl-font-sans);
      max-width: 600px;
      margin: 2rem auto;
      padding: 0 1rem;
    }
    
    .form-group {
      margin-bottom: 1.5rem;
    }
    
    .form-actions {
      display: flex;
      gap: 1rem;
      justify-content: flex-end;
      margin-top: 2rem;
    }
    
    .error-message {
      color: var(--sl-color-danger-600);
      font-size: var(--sl-font-size-small);
      margin-top: 0.25rem;
    }
  </style>
</head>
<body>
  <h1>Create Leave Request</h1>
  
  <!-- Error Alert (hidden by default) -->
  <sl-alert id="form-error" variant="danger" closable style="display: none; margin-bottom: 1rem;">
    <sl-icon slot="icon" name="exclamation-octagon"></sl-icon>
    <strong>Error</strong><br />
    <span id="error-message"></span>
  </sl-alert>
  
  <!-- Form -->
  <form 
    hx-post="/api/leave-requests"
    hx-target="#form-response"
    hx-indicator="#loading"
    hx-on::after-request="handleFormResponse(event)"
  >
    
    <!-- Leave Type -->
    <div class="form-group">
      <sl-select 
        name="leaveTypeId"
        label="Leave Type"
        placeholder="Select leave type"
        required
        hx-get="/api/leave-types?status=ACTIVE"
        hx-trigger="load"
        hx-target="this"
        hx-swap="innerHTML"
      >
        <sl-option value="">Loading...</sl-option>
      </sl-select>
      <div class="help-text">Select the type of leave you want to request</div>
    </div>
    
    <!-- Start Date -->
    <div class="form-group">
      <sl-input
        type="date"
        name="startDate"
        label="Start Date"
        required
        min="${new Date().toISOString().split('T')[0]}"
        hx-on:change="calculateTotalDays()"
      ></sl-input>
    </div>
    
    <!-- End Date -->
    <div class="form-group">
      <sl-input
        type="date"
        name="endDate"
        label="End Date"
        required
        hx-on:change="calculateTotalDays()"
      ></sl-input>
    </div>
    
    <!-- Total Days (computed) -->
    <div class="form-group">
      <sl-input
        type="number"
        name="totalDays"
        label="Total Days"
        readonly
        value="0"
      ></sl-input>
    </div>
    
    <!-- Reason -->
    <div class="form-group">
      <sl-textarea
        name="reason"
        label="Reason (Optional)"
        maxlength="500"
        rows="3"
        help-text="Maximum 500 characters"
      ></sl-textarea>
    </div>
    
    <!-- Actions -->
    <div class="form-actions">
      <sl-button variant="default" onclick="history.back()">
        Cancel
      </sl-button>
      <sl-button variant="primary" type="submit">
        <sl-icon slot="prefix" name="check"></sl-icon>
        Submit Request
      </sl-button>
    </div>
    
    <!-- Loading Indicator -->
    <sl-spinner id="loading" style="display: none;"></sl-spinner>
  </form>
  
  <div id="form-response"></div>
  
  <script>
    // Handle form response
    function handleFormResponse(event) {
      const xhr = event.detail.xhr;
      
      if (xhr.status === 201) {
        // Success
        const alert = Object.assign(document.createElement('sl-alert'), {
          variant: 'success',
          closable: true,
          duration: 3000,
          innerHTML: `
            <sl-icon slot="icon" name="check-circle"></sl-icon>
            <strong>Success!</strong><br />
            Leave request submitted successfully.
          `
        });
        document.body.appendChild(alert);
        alert.toast();
        
        // Redirect after 2 seconds
        setTimeout(() => {
          window.location.href = '/leave-requests';
        }, 2000);
      } else {
        // Error
        const error = JSON.parse(xhr.responseText);
        document.getElementById('error-message').textContent = error.message;
        document.getElementById('form-error').style.display = 'block';
      }
    }
    
    // Calculate total days
    function calculateTotalDays() {
      const startDate = document.querySelector('[name="startDate"]').value;
      const endDate = document.querySelector('[name="endDate"]').value;
      
      if (startDate && endDate) {
        const start = new Date(startDate);
        const end = new Date(endDate);
        const diffTime = Math.abs(end - start);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
        
        document.querySelector('[name="totalDays"]').value = diffDays;
      }
    }
  </script>
</body>
</html>
```

---

## Variations

### For List/Table View
```
Generate a list view for {ResourceName} with:

Features:
- Table with columns: {column1}, {column2}, {column3}
- Pagination (20 items per page)
- Filtering by {field1}, {field2}
- Sorting by {field}
- Search box
- Actions: View, Edit, Delete

API Endpoint: GET /api/{resources}

Use:
- sl-table for the table
- sl-pagination for pagination
- sl-input for search
- sl-select for filters
- HTMX for loading data and handling actions
```

### For Modal/Dialog
```
Generate a modal dialog for {ActionName}:

Trigger: Click button with id "{button-id}"
Content: {Description of modal content}
Actions: {List of buttons}
API Call: {Method} {Endpoint}

Use:
- sl-dialog for the modal
- HTMX for form submission
- Handle success/error within modal
```

### For Dashboard/Cards
```
Generate a dashboard with cards showing:

Card 1: {Title}
  - Data: {What to display}
  - API: GET {endpoint}
  
Card 2: {Title}
  - Data: {What to display}
  - API: GET {endpoint}

Use:
- sl-card for each card
- HTMX for loading data
- Auto-refresh every {N} seconds
```

---

## Tips for Better Results

### DO ✅
- Provide complete UI spec with all components and interactions
- Include API endpoints with request/response schemas
- Specify validation rules clearly
- Mention loading states and error handling
- Indicate responsive behavior requirements
- Specify accessibility requirements

### DON'T ❌
- Expect AI to design the UI (provide the design in spec)
- Forget to specify API endpoints
- Leave out error handling requirements
- Mix multiple screens in one request (do one at a time)

---

## Follow-up Prompts

After initial generation, you can refine:

```
"Add client-side validation for the email field"

"Add a loading skeleton while data is being fetched"

"Make the form responsive for mobile devices"

"Add a confirmation dialog before deleting"

"Add keyboard shortcuts (Ctrl+S to save, Esc to cancel)"

"Add field-level error display for validation errors"

"Add a success toast notification after save"
```

---

## Quality Checklist

Generated UI code should:
- [ ] Use semantic HTML5
- [ ] Use Shoelace components correctly
- [ ] Use HTMX for all server interactions
- [ ] Include proper form validation
- [ ] Handle loading states
- [ ] Display errors appropriately
- [ ] Be accessible (ARIA labels, keyboard navigation)
- [ ] Be responsive
- [ ] Include comments for complex logic
- [ ] Follow naming conventions
- [ ] Have clean, readable code

---

## Related Prompts
- [Generate Concept from Ontology](./generate-concept-from-ontology.md)
- [Generate API from Ontology](./generate-api-from-ontology.md)
- [Generate Tests from Scenarios](./generate-tests-from-scenarios.md)
