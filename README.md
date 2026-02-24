# Customer App 🧭

## Overview

Customer App allows users to book nearby guards and track them in real time.

Main flow:

```
Login → View Online Guards → Select Date & Time → Book → Track Guard → Ride Completed
```

---

## Features

### 🔐 Authentication

* Firebase Phone OTP Login
* Persistent session

---

### 📍 Location Detection

* Gets user live location
* Calculates distance to guards
* Sorts guards by nearest distance

---

### 👮 Guard Listing

Displays:

* Guard name
* Online status
* Distance from customer

Only online guards are shown.

---

### 📅 Booking System

Customer selects:

* Booking Date
* Booking Time

Booking data stored in Firestore.

---

### 📦 Ride Creation

Creates new ride document:

```
rides/{rideId}
```

with:

```
customerId
guardId
status = pending
bookingDate
bookingTime
latitude
longitude
```

---

### 🗺 Live Tracking

After acceptance:

* Customer tracks guard location live using Google Maps.
* Marker updates automatically.

---

### Ride States

```
pending  -> waiting for acceptance
accepted -> live tracking
completed -> ride finished
rejected -> request denied
```

---

## Architecture

### Service Layer

Firestore logic handled by:

```
RideService
```

UI remains clean and separated.

---

## Firebase Collections Used

### guards

Used for:

* Online guard listing
* Guard live location

### rides

Used for:

* Booking
* Ride status
* Tracking flow

---

## Tech Stack

* Flutter
* Firebase Authentication
* Cloud Firestore
* Geolocator
* Google Maps Flutter

---

## Setup

### 1. Install dependencies

```
flutter pub get
```

### 2. Firebase config

Add:

```
android/app/google-services.json
```

---

### 3. Run app

```
flutter run
```

---

## Demo Flow

1. Login using OTP
2. View nearby online guards
3. Select booking date & time
4. Book guard
5. Guard accepts request
6. Track guard live on map
7. Ride completion screen

---

## Internship Task Coverage

✔ Phone Authentication
✔ Guard Listing
✔ Distance Calculation
✔ Booking Date & Time
✔ Ride Status System
✔ Real-time Tracking
✔ Firestore Integration

---

## Author

Ezio
