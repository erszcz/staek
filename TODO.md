# ToDo

- [x] group default currency
- [ ] new group: choose members
- [x] existing group: add new member
- [ ] existing group: delete a member
    - [ ] check member balance before removing them
- [x] default screen: groups, discard the dashboard view
- [ ] middle section is extended to the width of right sections total height,
      which leaves space not consumed by expenses
- [x] group balance icon sizes don't match
- [x] prohibit expenses without debits and credits from being created
- [x] create debits and credits on expense creation based on the form data
- [ ] support non-equal expense credit/debit assignments
- [ ] fold group balances and group members into an accordion
- [ ] redesign the main group expenses view to use fixed columns instead of flex divs with basis
- [ ] should a user be able to see a group they're not a member of?


## Elixir Desktop

- [ ] Why do assets sometimes disappear?
  After merging branches main and umbrella and rebuilding the app, assets disappeared.
  This seems to work again, but I don't know what the triggers here are.

- [x] Does the desktop webview run JavaScript?
  Test with a simple alert triggered by a button click.
  Answer: yes, it does, for example an alert gets displayed in a new dialog.

- [ ] Why does the desktop release try to use the web release's endpoint port?
  This prevents the desktop and web releases from running side by side.

- [ ] Set up Marmot to enable database syncing between a desktop/mobile
  node and a web / backend node.


## Local first

- [ ] `db_version` should be stored persistently across app restarts to avoid resending
  db history since its creation
- [ ] watch out for out of order messages and missing updates!
- [ ] verify if it's safe to apply the changes,
  i.e. there's no gap between our `db_version` and `from_db_version`
