## Bugs
1. Storage permission issue (for CSV import export)~~ (Resolved: Storage permission requested on first start & on-demand during CSV export/import)
2. Monthly budget progress-bar rendering issue in 'today' & 'this week'~~ (Resolved: Monthly budget progress bar accurately computes current month's expenses vs monthly target budget across all date filter periods)
3. Back Navigation issue (app must close on 'back' from 'dashboard' screen)~~ (Resolved: Back gesture/button on non-dashboard tabs navigates back to Dashboard; back on Dashboard exits the app)
4. Add invisible card in the end of 'Expense Categories' and 'Income Categories' list in 'Manage Categories' to avoid '+' (add category) button underlapping~~ (Resolved: Added invisible spacer card at the end of category lists to avoid FAB overlap)
5. Add icons to feature tabs of 'app lock configuration' in 'Security & Privacy' settings
    5.1 yellow (same as 'Change Security PIN') 'lock_clock' icon for 'Auto-Lock Interval' without green square around it
    5.2 ~~'password' icon for 'Change Security PIN'~~ (Resolved: Added password_rounded icon in theme highlight color matching Change Security PIN)
6. Bruite-force attack on Security PIN is currently possible

## Features
- In 'Reset App Data' feature, user must get warning (confirm) after clicking on 'Reset Database & Start Fresh' button and before 'Confirm Pin'
- DRM Protection toggle in settings
- 'Stats' features
- Themes
- On tapping section of pie-chart, navigate user to 'Transactions' with category pre-selected according to the pie-chart section.