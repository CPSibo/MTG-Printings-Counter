# MTG Printings Counter
This utility counts all of the unique printings for cards in a MTG set. For instance, if the card with collector number 42 has non-foil, foil, and etched foil versions, it will be shown as having 3 printings. This is useful for planning collections and organizing binders.

You can run this via powershell on windows.

## Examples
### Basic
```ps
.\getMtgSetPrintings.ps1 -setCode "fnd"
```
This will output all cards found with their number of finishes, plus total counts below. `setCode` refers to the [three-letter code given to sets on scryfall](https://scryfall.com/sets).

### Minimum Finishes
```ps
.\getMtgSetPrintings.ps1 -setCode "fnd" -minFinishes 3
```
This will restrict the card output to only ones with at least `minFinishes` finishes. The totals at the bottom are unaffected by `minFinishes`.


