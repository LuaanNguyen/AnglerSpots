# Angler Spots 🎣

Many existing fishing apps require subscriptions or paid features. **AnglerSpots** is a simple, free app where people can mark their favorite fishing spots on a map, log catches, and leave useful notes for others.

## File Structure

The project will be structured using MVVM architecture with SwiftUI. We basically store fishing spot data and user posts, the View will include the SwiftUI map and lists, and the ViewModel will handle logic such as fetching data, filtering spots, and connecting with APIs. Organizing the app in this way will keep the code modular, easier to maintain, and more aligned with best practices we study in class.

```
AnglerSpots/
├── Models/
│   ├── Spot.swift
│   └── Catch.swift
├── Views/
│   ├── MapScreen.swift
│   ├── SpotsListScreen.swift
│   ├── SpotsDetailView.swift (includes EditSpotView)
│   ├── AddSpotView.swift
│   └── AddCatchView.swift
├── ViewModels/
│   └── SpotsViewModel.swift
├── Services/
│   ├── LocationManager.swift
│   └── WeatherService.swift
└── AnglerSpots/
    ├── AnglerSpotsApp.swift
    └── ContentView.swift
```
