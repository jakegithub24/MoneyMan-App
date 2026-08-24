## Bugs
1. Storage permission issue (for CSV import export)~~ (Resolved: Storage permission requested on first start & on-demand during CSV export/import)
2. Monthly budget progress-bar rendering issue in 'today' & 'this week'~~ (Resolved: Monthly budget progress bar accurately computes current month's expenses vs monthly target budget across all date filter periods)
3. Back Navigation issue (app must close on 'back' from 'dashboard' screen)~~ (Resolved: Back gesture/button on non-dashboard tabs navigates back to Dashboard; back on Dashboard exits the app)
4. Add invisible card in the end of 'Expense Categories' and 'Income Categories' list in 'Manage Categories' to avoid '+' (add category) button underlapping~~ (Resolved: Added invisible spacer card at the end of category lists to avoid FAB overlap)
5. Add icons to feature tabs of 'app lock configuration' in 'Security & Privacy' settings
    5.1 Add 'lock_clock' icon before 'Auto-Lock Interval' without green square around it
    5.2 'password' icon for 'Change Security PIN'~~ (Resolved: Added password_rounded icon in theme highlight color matching Change Security PIN)
6. Bruite-force attack on Security PIN is currently possible
7. Unclear titles. 'Enter Security PIN', 'Confirm Security PIN', 'Enter Current Security PIN', 'Enter New Security PIN', etc.

## Features
- In 'Reset App Data' feature, user must get warning (confirm) after clicking on 'Reset Database & Start Fresh' button and before 'Confirm PIN'~~ (Resolved: Warning confirmation dialog is prompted immediately on tapping Reset Database & Start Fresh before proceeding to PIN confirmation)
- DRM Protection toggle in settings~~ (Resolved: Added DRM protection toggle in Security & Privacy settings; enable without PIN, disable requires PIN with biometrics excluded)
- 'Stats' features
- Themes
- On tapping section of pie-chart, navigate user to 'Transactions' with category pre-selected according to the pie-chart section.~~ (Resolved: Tapping pie-chart slices or legend items filters ExpenseListCubit by the tapped category and switches navigation to Transactions tab)
- Duress PIN (resets app if entered Duress PIN)
- In 'Spending Breakdown' on Dashboard, there must be toggle for ('Pie', 'Line') graphs~~ (Resolved: Added Pie/Line graph toggle in breakdown card. Pie chart includes Expense/Income segmented switch. Line chart shows green line/dots for Income and red line/dots for Expense with interactive tooltips and 10-year interval set buttons for All Time view)
    - Pie chart: Keep as it is, but add 'Income - Expense' switch so that user can see pie chart of income and expense.
    - Line chart: Line chart will have green line and dots for income, red line and dots for expense. If 'All Time' filter is selected on Dashboard, 'Income/Spending Breakdown' screen will display set of 10 years followed by scrollable set number buttons.