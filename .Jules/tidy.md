## 2024-05-18 - Fix RenderFlex Overflow in Action Buttons
**Erkenntnis:** In Dialogen oder Bottom Sheets verursachen lokalisierte Strings in Action Buttons, die als Row mit festen Abständen formatiert sind, häufig RenderFlex-Overflows, wenn der verfügbare Platz zu schmal ist.
**Aktion:** Ersetze die direkte Verwendung von Row durch OverflowBar (z. B. OverflowBar(spacing: 8, overflowSpacing: 8)), damit sich Buttons automatisch untereinander anordnen, falls sie horizontal nicht auf den Bildschirm passen.
