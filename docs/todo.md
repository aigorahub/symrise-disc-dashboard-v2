### **Module: Design**

#### **TASK-001: Implement True Similarity Objective in Design Module**

* **Task Title:** Add User-Selectable Test Objective to Design Module  
* **User Story:** As a researcher, I want to select a "similarity" or "difference" objective within the Design module so that sample size, power, and delta calculations accurately reflect my study's hypothesis.  
* **Detailed Description:** The Design module's calculation functions currently default to a "difference" objective. This needs to be a user-configurable parameter. A new UI control (e.g., radio buttons or a dropdown) should be added to the Design module allowing the user to select between "Similarity" (default) and "Difference". This selection must be passed to the backend functions in backend/scripts/design/test to ensure the correct statistical models are used.  
* **Acceptance Criteria:**  
  * A "Test Objective" selector is added to the Design module UI.  
  * The default selection for the objective is "Similarity".  
  * The user's selection is passed as an argument to the backend calculation functions.  
  * The underlying statistical calculations correctly switch between similarity and difference methodologies based on user input.  
* **Priority:** High  
* **Timestamp:** [1:50](https://www.youtube.com/watch?v=VIDEO_ID&t=110s) \- [2:20](https://www.youtube.com/watch?v=VIDEO_ID&t=140s)

#### **TASK-002: Implement "Size of Difference" Test Calculation**

* **Task Title:** Add "Size of Difference (SoD)" Test Calculations to Design Module  
* **User Story:** As a researcher, I want the ability to perform power and sample size calculations for a "Size of Difference" test to support this specific methodology.  
* **Detailed Description:** The Design module currently lacks support for "Size of Difference" calculations. This task involves integrating this functionality.  
  * This feature will be triggered when the user selects "Size of Difference (SoD)" from the test type list (see TASK-007).  
  * The backend should use the dod\_power function from the sensR R package for these calculations.  
  * When "Size of Difference" is selected, the "Test Objective" control (from TASK-001) must be automatically set and locked to "Difference".  
  * The backend functions in backend/scripts/design/test will need to be wrapped or extended to perform the reverse calculations for sample size and delta threshold using the dod\_power function.  
* **Acceptance Criteria:**  
  * The system can calculate power, sample size, and delta for the "Size of Difference" test.  
  * The dod\_power function is correctly integrated and utilized.  
  * Selecting the "SoD" test correctly disables the "Test Objective" selector and sets it to "Difference".  
* **Priority:** High  
* **Timestamp:** [4:58](https://www.youtube.com/watch?v=VIDEO_ID&t=298s) \- [5:54](https://www.youtube.com/watch?v=VIDEO_ID&t=354s)

#### **TASK-003: Modernize UI of the Design Module**

* **Task Title:** Redesign the Layout and Components of the Design Module  
* **User Story:** As a user, I want a cleaner and more modern interface in the Design module to improve usability and readability.  
* **Detailed Description:** The current UI is cluttered and outdated.  
  * **Header Zone:** Create a single, organized header section at the top of the module to house the primary selectors: "Select Test Type" and "Select Test Objective".  
  * **Test Selection:** Replace the large, red, text-based radio buttons for test selection with a modern dropdown menu or a more subtle set of checkboxes.  
  * **Layout:** Condense the layout by reducing the excessive vertical white space between the parameter input tabs (Sample Size, Power, Delta) and the calculation results output.  
  * **Buttons:** Restyle the "Calculate" button to have rounded corners and a more modern appearance.  
* **Acceptance Criteria:**  
  * The test type selector is a dropdown or modern checkbox group, not red text.  
  * The test type and objective selectors are grouped in a clean header.  
  * White space is reduced, making the layout more compact.  
  * The "Calculate" button has rounded corners.  
* **Priority:** Medium  
* **Timestamp:** [7:08](https://www.youtube.com/watch?v=VIDEO_ID&t=428s) \- [8:34](https://www.youtube.com/watch?v=VIDEO_ID&t=514s)

---

### **Module: Import & Load**

#### **TASK-004: Update Test Type List and Logic in Import Module**

* **Task Title:** Add, Remove, and Rename Test Types in the Import Module  
* **User Story:** As a researcher, I want to see an accurate and up-to-date list of available test types when importing data, including the new "Size of Difference" and "Double Tetrad" options.  
* **Detailed Description:** The list of test types in the Import module needs to be updated to match the new methodologies.  
  * **UI Component:** The UI for selecting a test type should be a dropdown menu, consistent with the Design module's new look.  
  * **Remove:** "Ranking against reference" and "Difference from control" must be removed as options.  
  * **Add:** "Size of Difference (SoD)" and "Double Tetrad" must be added to the list of selectable tests.  
  * **Objective Selector:** Add a "Test Objective" selector ("Similarity" vs. "Difference") to this module. "Similarity" is the default. If "Size of Difference" is selected as the test type, the objective must default to and be locked on "Difference".  
* **Acceptance Criteria:**  
  * The Import module features a dropdown for test type selection.  
  * The dropdown list is correctly updated (options removed and added as specified).  
  * A test objective selector is present.  
  * The test objective selector is correctly linked to the test type selection (i.e., locks for "SoD").  
* **Priority:** High  
* **Timestamp:** [8:54](https://www.youtube.com/watch?v=VIDEO_ID&t=534s) \- [9:42](https://www.youtube.com/watch?v=VIDEO_ID&t=582s)

#### **TASK-005: Implement Double Tetrad Data Handling**

* **Task Title:** Enable Processing and Separate Display for Double Tetrad Test Files  
* **User Story:** As a researcher, when I import a Double Tetrad data file, I want the system to automatically recognize it and prepare the data for two separate analyses.  
* **Detailed Description:** The backend needs to be able to handle a Double Tetrad test, which is effectively two tetrad tests within one file.  
  * **File Recognition:** The file loading logic in backend/scripts/load/functions must be updated to identify the Double Tetrad format based on the file structure (an example file will be provided).  
  * **Data Splitting:** Upon recognition, the backend must parse and split the data into two distinct datasets, one for each tetrad test.  
  * **Results Display:** In the Run module, the results for both tests (plots, summary tables, etc.) must be rendered separately but on the same page, with clear headings like "Test 1" and "Test 2" to differentiate them.  
* **Acceptance Criteria:**  
  * The system correctly identifies a Double Tetrad file upon upload.  
  * The data is successfully split into two separate test datasets.  
  * The Run module displays two distinct and clearly labeled sets of results.  
* **Priority:** High  
* **Timestamp:** [21:58](https://www.youtube.com/watch?v=VIDEO_ID&t=1318s)

---

### **Module: Run & Report**

#### **TASK-006: Refactor Run Module UI and Parameter Handling**

* **Task Title:** Clean Up Run Module UI and Implement Smart Defaults  
* **User Story:** As a user, I want the Run module to be less cluttered and to intelligently pre-fill parameters based on the test I selected during import.  
* **Detailed Description:** This task focuses on improving the user experience in the Run module.  
  * **Remove UI Elements:** Remove the "Test Objective" selector from this module, as it will now be set in the Import module. Also, remove the word "Adjust" from the "Adjust Alpha Level" label.  
  * **Flexible Inputs:** Change the input fields for "Delta Threshold" and "Significance Level" from dropdowns to free-text numerical inputs.  
  * **Smart Defaults:** Implement logic to pre-populate the "Delta Threshold" and "Significance Level" fields with default values based on the "Actual Standard" for the test type and objective chosen in the Import module. The reviewer will provide the "Actual Standard" document.  
* **Acceptance Criteria:**  
  * The "Test Objective" selector is no longer present in the Run module.  
  * "Delta Threshold" and "Significance Level" are text input fields.  
  * The fields are correctly pre-populated with "smart defaults" when the Run module loads.  
* **Priority:** High  
* **Timestamp:** [12:11](https://www.youtube.com/watch?v=VIDEO_ID&t=731s), [14:19](https://www.youtube.com/watch?v=VIDEO_ID&t=859s), [15:55](https://www.youtube.com/watch?v=VIDEO_ID&t=955s)

#### **TASK-007: Update Backend Logic for Run Module**

* **Task Title:** Ensure Backend Functions Correctly Use All User Inputs  
* **User Story:** As a researcher, I need to be confident that all the parameters I set (like test objective and one-sided vs. two-sided tests) are correctly used in the final analysis.  
* **Detailed Description:** The backend functions that are called from the Run module need to be updated to correctly use all the user's inputs from the Import and Run stages.  
  * **Test Objective Propagation:** Ensure the test\_objective ('similarity' or 'difference') selected in the Import module is correctly passed to and used by the analysis functions in backend/scripts/run/functions.  
  * **2AFC Sidedness:** For 2AFC tests, the user's input regarding which sample is expected to be higher (or "I don't know") must determine whether a one-sided or two-sided test is performed. This logic is missing and needs to be implemented.  
  * **Dynamic Confidence Interval:** The confidence interval used in the backend calculations must be dynamically derived from the user-provided alpha level (Confidence Interval \= 1 \- (2 \* alpha) for a two-sided test, or 1 \- alpha for one-sided, verify exact formula). The default of 90% is static and must be made dynamic.  
* **Acceptance Criteria:**  
  * The test objective set in the Import module is correctly applied during the Run analysis.  
  * The 2AFC analysis correctly performs a one-sided or two-sided test based on user input.  
  * The confidence interval is calculated dynamically based on the alpha level.  
* **Priority:** High  
* **Timestamp:** [10:41](https://www.youtube.com/watch?v=VIDEO_ID&t=641s), [13:19](https://www.youtube.com/watch?v=VIDEO_ID&t=799s)

#### **TASK-008: Add New Visualizations and Metrics to Run Module**

* **Task Title:** Implement "Traffic Light" Plot and Add "Correct Answers" Metric  
* **User Story:** As a researcher, I want to see a "traffic light" visualization for a quick go/no-go assessment and also view the raw number of correct answers for my test.  
* **Detailed Description:** This task adds new visual and data elements to the Run module's output tabs.  
  * **Traffic Light Plot:** In the third tab ("Summary"), create and add a new "traffic light" plot. This visualization will show colored regions (e.g., green, yellow, red) that provide context for the calculated D-prime value and its confidence interval. An example will be provided by the reviewer.  
  * **Correct Answers Metric:** The backend function should calculate the total number of correct answers/total test. This value must be displayed in the summary sentence of the second tab ("Detailed Results") and in the summary table of the third tab. This is NOT applicable for SoD.  
* **Acceptance Criteria:**  
  * A "traffic light" plot is present in the "Summary" tab.  
  * The plot correctly visualizes the D-prime and CI against the colored regions.  
  * The "Number of Correct Answers" is displayed in both the detailed results and summary table.  
* **Priority:** Medium  
* **Timestamp:** [19:16](https://www.youtube.com/watch?v=VIDEO_ID&t=1156s), [17:23](https://www.youtube.com/watch?v=VIDEO_ID&t=1043s)

#### **TASK-009: Overhaul Reporting to Generate PowerPoint**

* **Task Title:** Replace Word Document Export with a Templated PowerPoint Report  
* **User Story:** As a user, I want to generate a standardized, one-page PowerPoint summary of my test results instead of a Word document.  
* **Detailed Description:** The reporting feature needs a complete overhaul.  
  * **UI Change:** Remove the "Make Report" (for Word) and "Make Slides" buttons. Replace them with a single button labeled "Make Report".  
  * **Backend Change:** The new "Make Report" button will trigger a backend process that generates a PowerPoint file. The existing logic for Word export in backend/scripts/report/test must be removed.  
  * **Template Population:** This new process will use a provided PowerPoint template. It needs to populate two slides: a main summary slide with key results and plots, and a second slide for user comments.  
  * **Content:** The content for the slides will be a mix of the plots and tables already generated for the Run module and specific fields from the session (e.g., sample names, test parameters).  
* **Acceptance Criteria:**  
  * The UI contains a single "Make Report" button.  
  * Clicking the button triggers a download of a .pptx file.  
  * The generated PowerPoint contains two slides per test, populated with the correct data.  
  * The old Word-generation functionality is completely removed.  
* **Priority:** High  
* **Timestamp:** [23:48](https://www.youtube.com/watch?v=VIDEO_ID&t=1428s) \- [25:02](https://www.youtube.com/watch?v=VIDEO_ID&t=1502s)

#### **TASK-010: Standardize Terminology Across All Modules**

* **Task Title:** Ensure Consistent Labeling for Key Parameters  
* **User Story:** As a user, I want to see consistent terminology for parameters like "alpha" across the entire application to avoid confusion.  
* **Detailed Description:** A global search and replace is needed to standardize labels. Specifically, any instance of "Significance Level" or "Adjust Alpha Level" across the Design and Run modules should be changed to the more descriptive and consistent "Significance Level (alpha value)".  
* **Acceptance Criteria:**  
  * The label in the Design module is updated to "Significance Level (alpha value)".  
  * The label in the Run module is updated to "Significance Level (alpha value)".  
  * No other variations of the label exist in the UI.  
* **Priority:** Low  
* **Timestamp:** [2:43](https://www.youtube.com/watch?v=VIDEO_ID&t=163s), [12:20](https://www.youtube.com/watch?v=VIDEO_ID&t=740s)
