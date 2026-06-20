# Friedenheim

A tactical resource and party manager fantasy rogue-lite built with the **Godot 4 Engine**. 

In *Friedenheim*, players balance managing a crew of characters with distinct food traits and quirks at the camp/town markets, configure venture parameters, and send them out on perilous automated text combat runs to extract valuable loot and materials.

---

## 🛠️ Project Architecture

The codebase follows a strict component-based separation of data structures, core simulation loop logic, and visual interface presentation:

* **`src/autoloads/`** - Global engine state manager singletons (`GameManager`, `ConfigManager`).
* **`src/core/`** - Underlying game engine math formulas, auto-combat handlers, and venture logic processors.
* **`src/data/`** - Pure resource blueprints (`item_data.gd`), YARD compiler databases, and `.po` localization asset strings.
* **`src/shared/`** - Self-contained UI panels, layout scenes, and modular component buttons/slots sitting side-by-side with their controlling scripts.

## 🚀 Key Features Initialized

* **Localization (gettext):** Built-in support for English and Japanese text generation using optimized `.po`/`.pot` pipelines.
* **Persistent Configuration:** A universal `config.cfg` pipeline handling user display configurations (exclusive fullscreen toggles) and logarithmic audio slider volumes natively synced via Godot's `AudioServer`.
* **Modular Layouts:** A self-healing focus-capture overlay system supporting seamless mouse, keyboard, and controller menu navigation inputs.

---

## 💻 Tech Stack
* **Engine:** Godot 4+ (GDScript)
* **Database Rulesets:** YARD (Yet Another Registry Database)
* **Localization Standards:** GNU gettext utilities
