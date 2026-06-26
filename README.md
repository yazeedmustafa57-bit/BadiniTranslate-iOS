# Badini Translate – iOS App 📱

## Voraussetzungen (was du brauchst)

| Was | Kosten | Woher |
|---|---|---|
| **Mac** (macOS Ventura oder neuer) | – | Dein MacBook/iMac |
| **Xcode 15+** | Kostenlos | Mac App Store |
| **Apple Developer Account** | **99 $/Jahr** | https://developer.apple.com |
| **XcodeGen** (optional) | Kostenlos | `brew install xcodegen` |

---

## 1. Projekt öffnen

### Option A: Mit XcodeGen (einfach)

```bash
# XcodeGen installieren (einmalig)
brew install xcodegen

# Im Projektordner ausführen
cd /Pfad/zu/BadiniTranslate-iOS
xcodegen generate

# Öffnen
open BadiniTranslate.xcodeproj
```

### Option B: Manuell in Xcode

1. Xcode öffnen → **File → New → Project**
2. **iOS → App** → Next
3. Product Name: `BadiniTranslate`
4. Interface: **SwiftUI**, Language: **Swift**
5. Ort auswählen → Create
6. Die Datei `BadiniTranslateApp.swift` **überschreiben** mit meiner Datei
7. `Info.plist` ersetzen
8. `Assets.xcassets` ersetzen

---

## 2. Für den App Store vorbereiten

### Entwicklungsteam eintragen

In `project.yml` (Zeile 8) `DEVELOPMENT_TEAM` eintragen:

```
DEVELOPMENT_TEAM: "DEIN_TEAM_ID"
```

Deine Team-ID findest du unter: https://developer.apple.com/account → Membership

### App-Icon hinzufügen

- Ein 1024×1024 PNG-Bild in `Assets.xcassets/AppIcon.appiconset/` ablegen
- Im Xcode-Projekt unter **Assets** → **AppIcon** das Bild zuweisen

### Bundle-ID

Die Bundle-ID ist `com.badini.translate.ios` – muss in der App Store Connect registriert werden.

---

## 3. App Store Connect einrichten

1. Gehe zu https://appstoreconnect.apple.com
2. **Meine Apps → + → Neue App**
3. Name: `Badini Translate`
4. Bundle-ID: `com.badini.translate.ios` (vorher registrieren)
5. SKU: `BADINI001`
6. **App-Informationen ausfüllen:**
   - Beschreibung (DE + EN)
   - Screenshots (iPhone + iPad)
   - Kategorie: `Nachschlagewerke` oder `Utility`

---

## 4. App archivieren & hochladen

```bash
# In Xcode:
# 1. Product → Destination → Any iOS Device (oder dein iPhone)
# 2. Product → Archive
# 3. Im Organizer → Validate App → Distribute App
# 4. App Store Connect → Submit
```

---

## 5. Wichtige Hinweise

- ⏳ Apple prüft die App **1–3 Tage** (meist schneller bei einfachen WebView-Apps)
- ✅ Die App ist eine WebView – das ist erlaubt, solange die Website `translator-site-five.vercel.app` gehört
- ❌ **Dein Huawei kann die iOS-App nicht installieren** – iOS-Apps laufen NUR auf iPhone/iPad
- 📲 **Alternative für Huawei-Nutzer:** Installiere die Android APK von https://github.com/yazeedmustafa57-bit/BadiniTranslate/releases

---

## Dateien in diesem Ordner

```
BadiniTranslate-iOS/
├── README.md                   ← Diese Anleitung
├── project.yml                 ← XcodeGen Konfiguration
└── BadiniTranslate/
    ├── BadiniTranslateApp.swift ← Haupt-App (SwiftUI + WKWebView)
    ├── Info.plist               ← App-Konfiguration (Berechtigungen, etc.)
    └── Assets.xcassets/         ← App-Icon
